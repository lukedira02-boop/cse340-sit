import pool from "./db.js";

export async function getAllOrganizations() {
  const result = await pool.query(
    `SELECT id, name, description, image_path AS "imagePath", category
     FROM organizations
     ORDER BY name`
  );
  return result.rows;
}
