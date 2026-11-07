import 'dotenv/config';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pool from './models/database.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sql = await fs.readFile(path.join(__dirname, 'setup.sql'), 'utf8');

try {
    await pool.query(sql);
    console.log('Database schema and seed data created successfully.');
} finally {
    await pool.end();
}
