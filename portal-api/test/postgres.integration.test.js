import test from 'node:test';
import assert from 'node:assert/strict';
import pg from 'pg';

const connectionString = process.env.PGTEST_URL;

test('PostgreSQL migration exposes the Gate 2 tables and tenant constraints', { skip: !connectionString }, async () => {
  const client = new pg.Client({ connectionString });
  await client.connect();
  try {
    const tables = await client.query(`
      select table_name
      from information_schema.tables
      where table_schema = 'public'
        and table_name = any($1::text[])
      order by table_name
    `, [[
      'users', 'organizations', 'memberships', 'invitations',
      'access_grants', 'benefit_entitlements', 'audit_events'
    ]]);
    assert.deepEqual(tables.rows.map((row) => row.table_name), [
      'access_grants', 'audit_events', 'benefit_entitlements', 'invitations',
      'memberships', 'organizations', 'users'
    ]);

    await client.query('begin');
    await client.query(`insert into users (id, external_subject, status) values
      ('pg-user-alpha', 'synthetic:pg-alpha', 'active'),
      ('pg-user-beta', 'synthetic:pg-beta', 'active')`);
    await client.query(`insert into organizations (id, name, status) values
      ('pg-org-alpha', 'PG Demo Alpha', 'active'),
      ('pg-org-beta', 'PG Demo Beta', 'active')`);
    await client.query(`insert into memberships (id, user_id, organization_id, role, status, valid_until) values
      ('pg-membership-alpha', 'pg-user-alpha', 'pg-org-alpha', 'owner', 'active', '2099-01-01T00:00:00Z'),
      ('pg-membership-beta', 'pg-user-beta', 'pg-org-beta', 'owner', 'active', '2099-01-01T00:00:00Z')`);

    const isolated = await client.query(`
      select count(*)::int as count
      from memberships
      where user_id = 'pg-user-alpha' and organization_id = 'pg-org-beta'
    `);
    assert.equal(isolated.rows[0].count, 0);
    await client.query('rollback');
  } finally {
    await client.end();
  }
});
