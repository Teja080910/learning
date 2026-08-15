import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { pool } from './db.js';

// Runs src/lib/schema.sql against the configured database.
// Safe to run multiple times (all statements are idempotent).
const schemaPath = fileURLToPath(new URL('./schema.sql', import.meta.url));

try {
    const schema = await readFile(schemaPath, 'utf8');
    await pool.query(schema);
    console.log('Database schema is ready.');
} catch (error) {
    console.error('Error applying schema:', error);
    process.exitCode = 1;
} finally {
    await pool.end();
}
