// Logs one line per request with the status code and how long it took
function requestLogger(req, res, next) {
    const start = Date.now();

    res.on('finish', () => {
        const ms = Date.now() - start;
        const user = req.user ? ` user=${req.user.id}` : '';
        console.log(`${new Date().toISOString()} ${req.method} ${req.originalUrl} ${res.statusCode} ${ms}ms${user}`);
    });

    next();
}

module.exports = { requestLogger };
