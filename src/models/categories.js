import pool from "./db.js";

export const getAllCategories = async () => {
  const result = await pool.query(
    `SELECT id, name
     FROM categories
     ORDER BY name`
  );
  return result.rows;
};
