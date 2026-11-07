import 'dotenv/config';
import pg from 'pg';

const { Pool } = pg;

const connectionString = process.env.DATABASE_URL?.trim();

if (!connectionString) {
    throw new Error('DATABASE_URL is required');
}

if (
    process.env.NODE_ENV === 'production' &&
    /(localhost|127\.0\.0\.1|::1)/i.test(connectionString)
) {
    throw new Error('DATABASE_URL must point to the Render PostgreSQL database in production');
}

const pool = new Pool({
    connectionString,
    ssl: connectionString.includes('render.com') || process.env.NODE_ENV === 'production'
        ? { rejectUnauthorized: false }
        : false
});

export default pool;
