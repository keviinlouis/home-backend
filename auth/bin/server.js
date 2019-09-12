const port = process.env.NODE_PORT || 4000;

const server = require('../app/app.js');

server.listen(port, function () {
    console.log('Listening on '+port);
});

module.export = server;
