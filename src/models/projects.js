import pool from './database.js';

export const getProjects = async () => {
    const result = await pool.query(`
        SELECT
            p.id,
            p.name,
            p.description,
            p.location,
            p.schedule,
            o.name AS organization,
            COALESCE(
                array_agg(DISTINCT c.name) FILTER (WHERE c.id IS NOT NULL),
                ARRAY[]::varchar[]
            ) AS categories
        FROM projects p
        JOIN organizations o ON o.id = p.organization_id
        LEFT JOIN project_categories pc ON pc.project_id = p.id
        LEFT JOIN categories c ON c.id = pc.category_id
        GROUP BY p.id, o.name
        ORDER BY p.schedule, p.name
    `);
    return result.rows;
};
