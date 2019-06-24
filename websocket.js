var express = require('express');
var app = express();
var expressWs = require('express-ws')(app);

let counter = 0

app.use(function (req, res, next) {
    console.log('middleware');
    req.testing = 'testing';
    return next();
});

app.get('/', function(req, res, next){
    console.log('get route', req.testing);
    res.end();
});

app.ws('/count', function(ws, req) {
    console.log('test');
    ws.on('message', function(msg) {
        console.log(msg);
        counter++;
        expressWs.getWss('/count').clients.forEach(function(client){
            console.log(client);
            client.send(counter);
        })
    });
});

app.listen(3000, '10.100.0.53');
