//Import the mongoose module
const mongoose = require('mongoose');
const uniqueValidator = require('mongoose-unique-validator');

mongoose.plugin(uniqueValidator, { message: 'O campo {PATH} precisa ser único.' });

const databaseName = process.env.NODE_ENV === 'test' ? 'home_test' : 'home';

//Set up default mongoose connection
let mongoUrl = process.env.MONGO_URL + '/' + databaseName;

mongoose.connect(mongoUrl, { useNewUrlParser: true });

//Get the default connection
let db = mongoose.connection;

//Bind connection to error event (to get notification of connection errors)
db.on('error', console.error.bind(console, 'MongoDB connection error:'));

module.exports = mongoose;

