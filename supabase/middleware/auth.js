const { createClient } = require('@supabase/supabase-js');
const { supabase } = require('../supabase/client');

// Checks the Supabase access token from the Authorization header.
// On success req.user is the auth user and req.db is a client that
// runs queries as that user, so row level security still applies.
async function requireAuth(req, res, next) {
    const header = req.headers.authorization || '';
    const [scheme, token] = header.split(' ');

    if (scheme !== 'Bearer' || !token) {
        return res.status(401).json({ error: 'Missing access token' });
    }

    try {
        const { data, error } = await supabase.auth.getUser(token);
        if (error || !data.user) {
            return res.status(401).json({ error: 'Invalid or expired token' });
        }

        req.user = data.user;
        req.db = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
            global: { headers: { Authorization: `Bearer ${token}` } },
            auth: { persistSession: false },
        });
        next();
    } catch (err) {
        next(err);
    }
}

module.exports = { requireAuth };
