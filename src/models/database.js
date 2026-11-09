import 'dotenv/config';
import pg from 'pg';

const { Pool } = pg;

const connectionString = (process.env.DB_URL || process.env.DATABASE_URL || '').trim();

if (!connectionString) {
    throw new Error('DB_URL is required');
}

if (
    process.env.NODE_ENV === 'production' &&
    /(localhost|127\.0\.0\.1|::1)/i.test(connectionString)
) {
    throw new Error('DB_URL must point to the Render PostgreSQL database in production');
}

const pool = new Pool({
    connectionString,
    ssl: connectionString.includes('render.com') || process.env.NODE_ENV === 'production'
        ? { rejectUnauthorized: false }
        : false
});

let db = pool;

if (process.env.NODE_ENV === 'development' && process.env.ENABLE_SQL_LOGGING === 'true') {
    db = {
        async query(text, params) {
            try {
                const start = Date.now();
                const result = await pool.query(text, params);
                const duration = Date.now() - start;
                console.log('Executed query:', {
                    text: text.replace(/\s+/g, ' ').trim(),
                    duration: `${duration}ms`,
                    rows: result.rowCount
                });
                return result;
            } catch (error) {
                console.error('Error in query:', {
                    text: text.replace(/\s+/g, ' ').trim(),
                    error: error.message
                });
                throw error;
            }
        },

        async connect(...args) {
            return pool.connect(...args);
        },

        async end() {
            await pool.end();
        }
    };
}

export default db;
