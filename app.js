const port = process.env.NODE_PORT || 4000;

const path = require('path');
const fs = require('fs');

const bodyParser = require('body-parser');
const express = require('express');
const server = express();


server.use(bodyParser.urlencoded({extended: true}));
server.use(bodyParser.json());


//Routes
const directoryPath = path.join(__dirname, 'routes');

fs.readdir(directoryPath, function (err, files) {
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    }
    files.forEach(function (file) {
        const route = require('./routes/'+file);
        server.use(route);
    });
});

server.listen(port, '0.0.0.0', function () {
    console.log('Listening on '+port);
});

