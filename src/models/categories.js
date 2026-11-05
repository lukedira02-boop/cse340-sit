import pool from './database.js';

export const getAllCategories = async () => {
    const result = await pool.query(`
        SELECT category_id AS id, name
        FROM categories
        ORDER BY name
    `);
    return result.rows;
};

export const getCategories = getAllCategories;
