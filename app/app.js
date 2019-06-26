const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const express = require('express');

require('./db');

const server = express();

server.use(bodyParser.urlencoded({extended: true}));
server.use(bodyParser.json());

server.use(function (err, req, res, next) {
    res.status(err.status || 500).json({status: err.status, message: err.message})
});

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

module.exports = server;
