import { readFile } from 'node:fs/promises';
import { Client } from 'pg';
import { createInterface } from 'node:readline/promises';
import { stdin as input, stdout as output } from 'node:process';

const rl = createInterface({ input, output });
const connectionString = process.env.DATABASE_URL || await rl.question('Neon direct DATABASE_URL: ');
rl.close();
if (!connectionString) throw new Error('DATABASE_URL is required.');

const sql = await readFile(new URL('../migrations/0001_accounts.sql', import.meta.url), 'utf8');
const client = new Client({ connectionString });
await client.connect();
try {
  await client.query(sql);
  console.log('Applied migrations/0001_accounts.sql');
} finally {
  await client.end();
}
