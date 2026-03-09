import assert from 'node:assert/strict';
import test from 'node:test';
import { buildServer } from '../src/server.js';

test('liveness endpoint responds with ok', async t => {
  const server = buildServer();
  t.after(() => server.close());

  const response = await server.inject({
    method: 'GET',
    url: '/health/live',
  });

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.json(), {
    status: 'ok',
    service: '${{ values.name }}',
  });
});

test('readiness endpoint responds with ready', async t => {
  const server = buildServer();
  t.after(() => server.close());

  const response = await server.inject({
    method: 'GET',
    url: '/health/ready',
  });

  assert.equal(response.statusCode, 200);
  assert.deepEqual(response.json(), {
    status: 'ready',
    service: '${{ values.name }}',
  });
});
