import pool from "./db.js";

export async function getAllProjects() {
  const result = await pool.query(
    `SELECT p.id, p.name, p.description, p.schedule, p.image_path AS "imagePath",
            o.name AS "organizationName"
     FROM projects p
     JOIN organizations o ON o.id = p.organization_id
     ORDER BY p.name`
  );
  return result.rows;
}
