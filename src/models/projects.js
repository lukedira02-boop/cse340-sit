import pool from './database.js';

export const getAllProjects = async () => {
    const result = await pool.query(`
        SELECT
            p.project_id AS id,
            p.name,
            p.description,
            p.location,
            p.schedule,
            o.name AS organization,
            COALESCE(
                array_agg(DISTINCT c.name) FILTER (WHERE c.category_id IS NOT NULL),
                ARRAY[]::varchar[]
            ) AS categories
        FROM project p
        JOIN organization o ON o.organization_id = p.organization_id
        LEFT JOIN project_categories pc ON pc.project_id = p.project_id
        LEFT JOIN categories c ON c.category_id = pc.category_id
        GROUP BY p.project_id, o.name
        ORDER BY p.schedule, p.name
    `);
    return result.rows;
};

export const getProjects = getAllProjects;
