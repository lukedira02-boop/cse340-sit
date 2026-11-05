# Service Connect (CSE 340 W01)

Node.js + Express + EJS site.

## Run locally
    npm install
    cp .env.example .env
    npm start

Open http://127.0.0.1:3000

## Database setup
Set `DATABASE_URL` in `.env` to a PostgreSQL connection string, then initialize
the schema and seed data:

    npm run db:setup

The database is the only source of page data. The application does not use
static fallback data when a database query fails.

## Deploy on Render
- Build command: `npm install`
- Start command: `npm start`
- Set `NODE_ENV=production` in Render's environment settings (do not commit `.env`).
