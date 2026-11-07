import pool from "./db.js";

export const getAllOrganizations = async () => {
  const result = await pool.query(
    `SELECT id, name, description, image_path AS "imagePath"
     FROM organizations
     ORDER BY name`
  );
  return result.rows;
};
