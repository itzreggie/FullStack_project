const { test, before, after } = require('node:test');
const assert = require('node:assert/strict');

// The Supabase clients need these to load. None of the tests below
// reach Supabase, so dummy values are enough.
process.env.SUPABASE_URL = process.env.SUPABASE_URL || 'http://localhost:54321';
process.env.SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'test-anon-key';

const app = require('../app');

let server;
let baseUrl;

before(async () => {
    await new Promise((resolve) => {
        server = app.listen(0, resolve);
    });
    baseUrl = `http://127.0.0.1:${server.address().port}`;
});

after(() => {
    server.close();
});

test('GET /health reports that the server is running', async () => {
    const res = await fetch(`${baseUrl}/health`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'Backend is running');
    assert.ok(body.timestamp);
});

test('unknown paths return a JSON 404', async () => {
    const res = await fetch(`${baseUrl}/nope`);
    assert.equal(res.status, 404);
    assert.deepEqual(await res.json(), { error: 'Not found' });
});

test('API routes need a bearer token', async () => {
    const paths = [
        ['POST', '/api/devices/connect'],
        ['PATCH', '/api/devices/connections/1'],
        ['DELETE', '/api/devices/connections/1'],
        ['POST', '/api/safe-zones'],
        ['DELETE', '/api/safe-zones/1'],
        ['PUT', '/api/safe-zones/1/bounding-box'],
    ];
    for (const [method, path] of paths) {
        const res = await fetch(`${baseUrl}${path}`, { method });
        assert.equal(res.status, 401, `${method} ${path}`);
        assert.equal((await res.json()).error, 'Missing access token');
    }
});

test('a token with the wrong scheme is rejected', async () => {
    const res = await fetch(`${baseUrl}/api/safe-zones`, {
        method: 'POST',
        headers: { Authorization: 'Basic abc' },
    });
    assert.equal(res.status, 401);
});

test('malformed JSON returns 400', async () => {
    const res = await fetch(`${baseUrl}/api/safe-zones`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: '{"locationName": ',
    });
    assert.equal(res.status, 400);
    assert.ok((await res.json()).error);
});
