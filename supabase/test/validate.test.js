const test = require('node:test');
const assert = require('node:assert/strict');
const {
    requireString,
    requireLat,
    requireLng,
    requireId,
    requireDeviceCode,
} = require('../lib/validate');

function throws400(fn, message) {
    assert.throws(fn, (err) => {
        assert.equal(err.status, 400);
        if (message) assert.match(err.message, message);
        return true;
    });
}

test('requireString trims and returns the value', () => {
    assert.equal(requireString({ name: '  Home  ' }, 'name'), 'Home');
});

test('requireString rejects missing, blank and non string values', () => {
    throws400(() => requireString({}, 'name'), /name is required/);
    throws400(() => requireString({ name: '   ' }, 'name'), /name is required/);
    throws400(() => requireString({ name: 5 }, 'name'), /must be a string/);
});

test('requireString checks the length', () => {
    throws400(() => requireString({ name: 'abcdef' }, 'name', { maxLength: 5 }), /at most 5/);
});

test('optional strings return null when empty', () => {
    assert.equal(requireString({}, 'name', { optional: true }), null);
    assert.equal(requireString({ name: '  ' }, 'name', { optional: true }), null);
    assert.equal(requireString({ name: null }, 'name', { optional: true }), null);
});

test('latitude and longitude must be in range', () => {
    assert.equal(requireLat({ lat: 61.05 }, 'lat'), 61.05);
    assert.equal(requireLng({ lng: -180 }, 'lng'), -180);
    throws400(() => requireLat({ lat: 91 }, 'lat'));
    throws400(() => requireLng({ lng: 180.5 }, 'lng'));
    throws400(() => requireLat({ lat: '61' }, 'lat'), /must be a number/);
    throws400(() => requireLat({ lat: NaN }, 'lat'));
});

test('requireId accepts positive integers only', () => {
    assert.equal(requireId('12'), 12);
    throws400(() => requireId('0'));
    throws400(() => requireId('-3'));
    throws400(() => requireId('1.5'));
    throws400(() => requireId('abc'));
});

test('requireDeviceCode removes the dash and uppercases', () => {
    assert.equal(requireDeviceCode({ code: '12a-b34' }, 'code'), '12AB34');
    assert.equal(requireDeviceCode({ code: '12AB34' }, 'code'), '12AB34');
});

test('requireDeviceCode rejects bad codes', () => {
    throws400(() => requireDeviceCode({ code: '12A-B3' }, 'code'));
    throws400(() => requireDeviceCode({ code: '12A_B34' }, 'code'));
    throws400(() => requireDeviceCode({ code: '12AB345' }, 'code'));
});
