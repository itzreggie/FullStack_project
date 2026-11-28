const express = require('express');
const { supabaseAdmin } = require('../supabase/client');
const { requireDeviceCode, badRequest } = require('../lib/validate');

const router = express.Router();

// Express 4 does not catch rejected promises from async handlers
const wrap = (handler) => (req, res, next) => handler(req, res, next).catch(next);

// Connect the user's device to another device by its code.
// The other device belongs to someone else, so only the admin client
// can find it. Only its id is used.
router.post('/connect', wrap(async (req, res) => {
    const myCode = requireDeviceCode(req.body, 'myDeviceCode');
    const targetCode = requireDeviceCode(req.body, 'targetCode');

    if (myCode === targetCode) {
        throw badRequest('You cannot connect a device to itself');
    }

    const { data: myDevice, error: myError } = await req.db
        .from('device_locations')
        .select('id')
        .eq('generated_id', myCode)
        .maybeSingle();
    if (myError) throw myError;
    if (!myDevice) {
        return res.status(404).json({ error: 'Your device is not registered. Turn on tracking first.' });
    }

    const { data: target, error: targetError } = await supabaseAdmin
        .from('device_locations')
        .select('id')
        .eq('generated_id', targetCode)
        .maybeSingle();
    if (targetError) throw targetError;
    if (!target) {
        return res.status(404).json({ error: 'The code provided does not exist' });
    }

    const now = new Date().toISOString();

    const { data: existing, error: existingError } = await req.db
        .from('connected_devices')
        .select('id')
        .eq('device_location_id', myDevice.id)
        .eq('connected_device_id', target.id)
        .maybeSingle();
    if (existingError) throw existingError;

    if (existing) {
        const { data, error } = await req.db
            .from('connected_devices')
            .update({ generated_id: targetCode, last_connected: now })
            .eq('id', existing.id)
            .select()
            .single();
        if (error) throw error;
        return res.json(data);
    }

    const { data, error } = await req.db
        .from('connected_devices')
        .insert({
            device_location_id: myDevice.id,
            generated_id: targetCode,
            connected_device_id: target.id,
            owner_id: req.user.id,
            last_connected: now,
            created_at: now,
        })
        .select()
        .single();
    if (error) throw error;

    res.status(201).json(data);
}));

module.exports = router;
