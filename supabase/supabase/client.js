const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error('Missing SUPABASE_URL or SUPABASE_ANON_KEY');
}

const options = { auth: { persistSession: false, autoRefreshToken: false } };

const supabase = createClient(supabaseUrl, supabaseAnonKey, options);

// The admin client is only needed for migrations and device code lookups
const supabaseAdmin = supabaseServiceKey
    ? createClient(supabaseUrl, supabaseServiceKey, options)
    : null;

if (!supabaseAdmin) {
    console.warn('SUPABASE_SERVICE_ROLE_KEY is not set, admin features are off');
}

module.exports = {
    supabase,
    supabaseAdmin
};
