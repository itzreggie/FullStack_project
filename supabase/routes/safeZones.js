const express = require('express');
const { requireString, requireLat, requireLng, requireId } = require('../lib/validate');

const router = express.Router();

const wrap = (handler) => (req, res, next) => handler(req, res, next).catch(next);

router.post('/', wrap(async (req, res) => {
    const zone = {
        location_name: requireString(req.body, 'locationName'),
        location_address: requireString(req.body, 'locationAddress', { maxLength: 300, optional: true }) || '',
        location_lat: requireLat(req.body, 'locationLat'),
        location_lng: requireLng(req.body, 'locationLng'),
        user_id: req.user.id,
        created_at: new Date().toISOString(),
    };

    const { data, error } = await req.db
        .from('safe_zone')
        .insert(zone)
        .select()
        .single();
    if (error) throw error;

    res.status(201).json(data);
}));

// The bounding box rows go with it through ON DELETE CASCADE
router.delete('/:id', wrap(async (req, res) => {
    const id = requireId(req.params.id);

    const { data, error } = await req.db
        .from('safe_zone')
        .delete()
        .eq('id', id)
        .select('id');
    if (error) throw error;
    if (data.length === 0) {
        return res.status(404).json({ error: 'Safe zone not found' });
    }

    res.status(204).end();
}));

// Create or replace the four corner border of a safe zone
router.put('/:id/bounding-box', wrap(async (req, res) => {
    const safeZoneId = requireId(req.params.id);
    const now = new Date().toISOString();

    const box = { safe_zone_id: safeZoneId, updated_at: now };
    for (const point of ['a', 'b', 'c', 'd']) {
        const upper = point.toUpperCase();
        box[`point_${point}_lat`] = requireLat(req.body, `point${upper}Lat`);
        box[`point_${point}_lng`] = requireLng(req.body, `point${upper}Lng`);
    }
    box.location_name = requireString(req.body, 'locationName', { optional: true });

    const { data: zone, error: zoneError } = await req.db
        .from('safe_zone')
        .select('id')
        .eq('id', safeZoneId)
        .maybeSingle();
    if (zoneError) throw zoneError;
    if (!zone) {
        return res.status(404).json({ error: 'Safe zone not found' });
    }

    const { data: existing, error: existingError } = await req.db
        .from('bounding_box')
        .select('id')
        .eq('safe_zone_id', safeZoneId)
        .maybeSingle();
    if (existingError) throw existingError;

    if (existing) {
        const { data, error } = await req.db
            .from('bounding_box')
            .update(box)
            .eq('id', existing.id)
            .select()
            .single();
        if (error) throw error;
        return res.json(data);
    }

    box.created_at = now;
    const { data, error } = await req.db
        .from('bounding_box')
        .insert(box)
        .select()
        .single();
    if (error) throw error;

    res.status(201).json(data);
}));

module.exports = router;
