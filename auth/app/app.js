const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const express = require('express');
const helmet = require('helmet');
require('express-async-errors');
require('dotenv-safe').config();

require('./db');

const app = express();

app.use(helmet());
app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());

//Routes
const routesPath = path.join(__dirname, 'routes');

fs.readdir(routesPath, function (err, files) {
    if (err) {
        return console.log('Unable to scan directory: ' + err);
    }
    files.forEach(function (file) {
        const route = require('./routes/'+file);
        app.use(route);
    });
});

//Gateway
const {routerGenerator, services} = require('./gateway');

services.forEach(resource => {
    app.use(`/${resource}`, routerGenerator(resource));
});

module.exports = app;

