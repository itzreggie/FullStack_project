const fs = require('fs');
const path = require('path');
const { supabaseAdmin } = require('../supabase/client');

const MIGRATIONS_DIR = path.join(__dirname, '..', 'supabase', 'migrations');

async function runSql(query) {
    const { error } = await supabaseAdmin.rpc('execute_sql', { query });
    if (error) {
        throw new Error(error.message);
    }
}

async function getAppliedMigrations() {
    await runSql(`
        CREATE TABLE IF NOT EXISTS schema_migrations (
          name TEXT PRIMARY KEY,
          applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
        );
        NOTIFY pgrst, 'reload schema';
    `);

    // PostgREST reloads its schema cache in the background
    await new Promise((resolve) => setTimeout(resolve, 1000));

    const { data, error } = await supabaseAdmin
        .from('schema_migrations')
        .select('name');

    if (error) {
        throw new Error(error.message);
    }

    return new Set(data.map((row) => row.name));
}

async function migrate() {
    try {
        const files = fs.readdirSync(MIGRATIONS_DIR)
            .filter((file) => file.endsWith('.sql'))
            .sort();

        const applied = await getAppliedMigrations();
        let count = 0;

        for (const file of files) {
            if (applied.has(file)) {
                console.log(`Skipping ${file} (already applied)`);
                continue;
            }

            console.log(`Applying ${file}...`);
            const sql = fs.readFileSync(path.join(MIGRATIONS_DIR, file), 'utf8');
            await runSql(sql);

            const { error } = await supabaseAdmin
                .from('schema_migrations')
                .insert({ name: file });
            if (error) {
                throw new Error(error.message);
            }
            count++;
        }

        console.log(`Done. Applied ${count} migration(s).`);
    } catch (error) {
        console.error('Migration failed:', error.message);
        process.exitCode = 1;
    }
}

migrate();
