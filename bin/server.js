const port = process.env.NODE_PORT || 4000;

const server = require('../app/app.js');

server.listen(port, '0.0.0.0', function () {
    console.log('Listening on '+port);
});

