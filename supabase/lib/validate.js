// Small helpers for checking request bodies. Each one throws an
// error with status 400, which the error handler in app.js turns into
// a JSON response.

function badRequest(message) {
    const err = new Error(message);
    err.status = 400;
    return err;
}

function requireString(body, field, { maxLength = 200, optional = false } = {}) {
    const value = body[field];
    if (value === undefined || value === null || value === '') {
        if (optional) return null;
        throw badRequest(`${field} is required`);
    }
    if (typeof value !== 'string') {
        throw badRequest(`${field} must be a string`);
    }
    const trimmed = value.trim();
    if (trimmed.length === 0) {
        if (optional) return null;
        throw badRequest(`${field} is required`);
    }
    if (trimmed.length > maxLength) {
        throw badRequest(`${field} must be at most ${maxLength} characters`);
    }
    return trimmed;
}

function requireNumber(body, field, { min = -Infinity, max = Infinity } = {}) {
    const value = body[field];
    if (typeof value !== 'number' || Number.isNaN(value)) {
        throw badRequest(`${field} must be a number`);
    }
    if (value < min || value > max) {
        throw badRequest(`${field} must be between ${min} and ${max}`);
    }
    return value;
}

function requireLat(body, field) {
    return requireNumber(body, field, { min: -90, max: 90 });
}

function requireLng(body, field) {
    return requireNumber(body, field, { min: -180, max: 180 });
}

function requireId(value, field = 'id') {
    const id = Number(value);
    if (!Number.isInteger(id) || id <= 0) {
        throw badRequest(`${field} must be a positive integer`);
    }
    return id;
}

// Device codes look like ABC-123 in the app and are stored without the dash
function requireDeviceCode(body, field) {
    const raw = requireString(body, field, { maxLength: 7 });
    const code = raw.replace('-', '').toUpperCase();
    if (!/^[0-9A-Z]{6}$/.test(code)) {
        throw badRequest(`${field} must be a 6 character device code`);
    }
    return code;
}

module.exports = {
    badRequest,
    requireString,
    requireNumber,
    requireLat,
    requireLng,
    requireId,
    requireDeviceCode,
};
