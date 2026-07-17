#!/usr/bin/env node

const http = require('http');

const PORT = 80;

const server = http.createServer((req, res) => {
    // 1. Extract the host name (e.g., example.com)
    const host = req.headers.host;

    // 2. Fallback to prevent crashes if the host header is missing
    if (!host) {
        res.writeHead(400, { 'Content-Type': 'text/plain' });
        res.end('Bad Request: Missing Host Header');
        return;
    }

    // 3. Construct the destination secure URL
    const targetUrl = `https://${host}${req.url}`;

    // 4. Issue the 301 Permanent Redirect headers
    res.writeHead(301, { 'Location': targetUrl });
    res.end();
});

// 5. Start listening on port 80
server.listen(PORT, () => {
    console.log(`HTTP redirect server running on port ${PORT}`);
});

// 6. Graceful error handling (e.g., if port 80 is already in use)
server.on('error', (err) => {
    console.error('Server error:', err.message);
});
