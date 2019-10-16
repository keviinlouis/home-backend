const path = require('path');
const fs = require('fs');
const bodyParser = require('body-parser');
const express = require('express');
const helmet = require('helmet');
require('express-async-errors');
require('dotenv-safe').config();

require('./db');

const app = express();
const server = require('http').Server(app);
const io = require('socket.io')(server);

const connectedUsers = {};

io.on('connection', socket => {
    const { user } = socket.handshake.query;
    console.log(user, socket.id);
    connectedUsers[user] = socket.id;
    socket.on('disconnect', function () {
        delete connectedUsers[user]
    });
});

app.use((request, response, next) => {
    request.io = io;
    request.connectedUsers = connectedUsers;

    return next();
});

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

//Consumer
const {consumer} = require('./kafka.js');

consumer.init().then(() => {
    consumer.subscribe('bill_event',0, function(messageSet, topic, partition){
        const billEventAsJson = messageSet[0].message.value.toString();
        const billEvent = JSON.parse(billEventAsJson);

        if(billEvent.kind === 'message'){
            const socketPath = `bill_event.${billEvent.bill_id}.new`;
            const usersIds = billEvent.notify_users;
            usersIds.forEach((userId) => {
                const targetSocket = connectedUsers[userId];
                if(targetSocket){
                    io.to(targetSocket).emit(socketPath, billEventAsJson)
                }
            });
        }
    })
});

module.exports = server;

