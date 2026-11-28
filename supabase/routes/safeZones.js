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

module.exports = router;
