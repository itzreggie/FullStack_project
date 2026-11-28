const express = require('express');
const cors = require('cors');
const { requireAuth } = require('./middleware/auth');
const devicesRouter = require('./routes/devices');
const safeZonesRouter = require('./routes/safeZones');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
    res.json({ status: 'Backend is running', timestamp: new Date().toISOString() });
});

app.use('/api/devices', requireAuth, devicesRouter);
app.use('/api/safe-zones', requireAuth, safeZonesRouter);

app.use((req, res) => {
    res.status(404).json({ error: 'Not found' });
});

// Express needs all four arguments to treat this as an error handler
app.use((err, req, res, next) => {
    console.error(err);
    const status = err.status || 500;
    res.status(status).json({
        error: status === 500 ? 'Internal server error' : err.message,
    });
});

module.exports = app;
