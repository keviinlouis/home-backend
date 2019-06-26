//Import the mongoose module
let mongoose = require('mongoose');

//Set up default mongoose connection
let mongoUrl = 'mongodb://mongo:27017/home';
mongoose.connect(mongoUrl, { useNewUrlParser: true });

//Get the default connection
let db = mongoose.connection;

//Bind connection to error event (to get notification of connection errors)
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

module.exports = mongoose;

