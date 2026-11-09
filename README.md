# Service Connect (CSE 340)

Node.js + Express + EJS site.

## Run locally
```powershell
npm install
Copy-Item .env.example .env
```

Set `DB_URL` in `.env` to your PostgreSQL connection string and optionally enable `ENABLE_SQL_LOGGING=true` for debugging, then run:

```powershell
npm start
```

Open http://127.0.0.1:3000

On first startup, the app creates and seeds its tables if the database is empty.
If the database contains only the valid `organization` table from the earlier
course activity, it preserves that table and adds the remaining schema and seed
data. It leaves a fully initialized database unchanged and stops with an error
for other partial schemas rather than dropping existing data.
The role in `DB_URL` must be allowed to use and create tables in the
`public` schema. If startup reports missing permissions, connect to the same
database as its owner or an administrator and grant the required access to the
application role (replace `app_role` with the role reported in the startup
error):

```sql
GRANT USAGE, CREATE ON SCHEMA public TO app_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_role;
```

The `SELECT` grant is needed when tables were created by a different role.
Do not grant permissions to `PUBLIC`. Make sure `DB_URL` points to the
intended database and uses the exact name configured by the provider; database
name capitalization is separate from schema permissions.

You can also initialize or complete the database explicitly:

    npm run db:setup

The database is the only source of page data. The application does not use
static fallback data when a database query fails.

## Deploy on Render
- Build command: `npm install`
- Start command: `npm start`
- Set `NODE_ENV=production` in Render's environment settings (do not commit `.env`).
- Link the Render PostgreSQL database through `DB_URL` and set `ENABLE_SQL_LOGGING=true` while debugging.
- On the first start, the app creates and seeds tables if the database is empty, or completes a valid organization-only schema.
