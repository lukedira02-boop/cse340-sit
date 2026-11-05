import pool from './database.js';

export const getOrganizations = async () => {
    const result = await pool.query(`
        SELECT id, name, description, email, logo
        FROM organizations
        ORDER BY name
    `);
    return result.rows;
};
