import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pool from './models/database.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.join(__dirname, 'setup.sql');
const applicationTables = [
    'organization',
    'categories',
    'project',
    'project_categories'
];

const verifyExistingOrganizationTable = async (client) => {
    const { rows: columns } = await client.query(`
        SELECT column_name, data_type, character_maximum_length, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'organization'
    `);
    const expectedColumns = [
        ['organization_id', 'integer', null],
        ['name', 'character varying', 150],
        ['description', 'text', null],
        ['contact_email', 'character varying', 255],
        ['logo_filename', 'character varying', 255]
    ];
    const hasExpectedColumns = expectedColumns.every(([name, dataType, maxLength]) => {
        const column = columns.find((item) => item.column_name === name);
        return column &&
            column.data_type === dataType &&
            column.character_maximum_length === maxLength &&
            column.is_nullable === 'NO';
    });
    const organizationId = columns.find((column) => column.column_name === 'organization_id');
    const { rows: [primaryKey] } = await client.query(`
        SELECT EXISTS (
            SELECT 1
            FROM pg_constraint constraint_info
            JOIN pg_attribute attribute_info
              ON attribute_info.attrelid = constraint_info.conrelid
             AND attribute_info.attname = 'organization_id'
            WHERE constraint_info.conrelid = 'public.organization'::regclass
              AND constraint_info.contype = 'p'
              AND array_length(constraint_info.conkey, 1) = 1
              AND constraint_info.conkey[1] = attribute_info.attnum
        ) AS has_primary_key
    `);

    if (
        !hasExpectedColumns ||
        !organizationId?.column_default?.startsWith("nextval(") ||
        !primaryKey.has_primary_key
    ) {
        throw new Error(
            'The existing organization table does not match the expected CSE 340 schema. ' +
            'Resolve its columns, serial primary key, and constraints before initializing the remaining tables.'
        );
    }
};

export const initializeDatabase = async () => {
    const client = await pool.connect();

    try {
        await client.query('BEGIN');
        await client.query('SELECT pg_advisory_xact_lock(3400, 3400)');

        const { rows: [connection] } = await client.query(`
            SELECT
                current_database() AS database,
                current_user AS role,
                has_schema_privilege(current_user, 'public', 'USAGE') AS can_use_schema,
                has_schema_privilege(current_user, 'public', 'CREATE') AS can_create
        `);
        const tableChecks = applicationTables
            .map((table) => `to_regclass('public.${table}') IS NOT NULL AS "${table}"`)
            .join(', ');
        const { rows: [tables] } = await client.query(`SELECT ${tableChecks}`);
        const existingTables = applicationTables.filter((table) => tables[table]);

        if (existingTables.length === applicationTables.length) {
            let tablesWithoutSelect = [];

            if (connection.can_use_schema) {
                const { rows: [tablePrivileges] } = await client.query(`
                    SELECT ${applicationTables
                        .map((table) =>
                            `has_table_privilege(current_user, 'public.${table}', 'SELECT') AS "${table}"`
                        )
                        .join(', ')}
                `);
                tablesWithoutSelect = applicationTables.filter(
                    (table) => !tablePrivileges[table]
                );
            }

            if (!connection.can_use_schema || tablesWithoutSelect.length > 0) {
                const missingPermissions = [
                    ...(!connection.can_use_schema ? ['USAGE on schema public'] : []),
                    ...(tablesWithoutSelect.length > 0
                        ? [`SELECT on tables ${tablesWithoutSelect.join(', ')}`]
                        : [])
                ];
                throw new Error(
                    `Database role "${connection.role}" lacks ${missingPermissions.join(' and ')} ` +
                    `in database "${connection.database}". Ask the database owner or administrator ` +
                    'to grant the missing permissions.'
                );
            }

            await client.query('COMMIT');
            return false;
        }

        const existingOrganizationsOnly =
            existingTables.length === 1 && existingTables[0] === 'organization';

        if (existingTables.length > 0 && !existingOrganizationsOnly) {
            const missingPermissions = [
                ...(!connection.can_use_schema ? ['USAGE'] : []),
                ...(!connection.can_create ? ['CREATE'] : [])
            ];
            const permissionHint = missingPermissions.length > 0
                ? ` Database role "${connection.role}" also lacks ${missingPermissions.join(' and ')} ` +
                    'on schema "public".'
                : '';
            throw new Error(
                `Database schema is incomplete; found ${existingTables.join(', ')}. ` +
                `Resolve the existing schema before initializing it.${permissionHint}`
            );
        }

        if (!connection.can_use_schema || !connection.can_create) {
            const missingPermissions = [
                ...(!connection.can_use_schema ? ['USAGE'] : []),
                ...(!connection.can_create ? ['CREATE'] : [])
            ];
            throw new Error(
                `Database role "${connection.role}" lacks ${missingPermissions.join(' and ')} ` +
                `on schema "public" in database "${connection.database}". Ask the database ` +
                'owner or administrator to grant the missing permissions.'
            );
        }

        if (existingOrganizationsOnly) {
            await verifyExistingOrganizationTable(client);
        }

        const schema = await fs.readFile(schemaPath, 'utf8');
        await client.query(schema);
        await client.query('COMMIT');
        return true;
    } catch (error) {
        await client.query('ROLLBACK');
        throw error;
    } finally {
        client.release();
    }
};
