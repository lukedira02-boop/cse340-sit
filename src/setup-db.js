import 'dotenv/config';
import pool from './models/database.js';
import { initializeDatabase } from './initialize-db.js';

try {
    const initialized = await initializeDatabase();
    console.log(
        initialized
            ? 'Database schema and seed data created successfully.'
            : 'Database schema is already initialized.'
    );
} finally {
    await pool.end();
}
