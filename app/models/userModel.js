//Require Mongoose
let mongoose = require('mongoose');

//Define a schema
let User = mongoose.Schema;

let UserModelSchema = new User({
    email: {
        type: String,
        required: [true, 'Você precisa de um email']
    },
    name: {
        type: String,
        required: [true, 'Precisamos te chamar por algum nome né?']
    },
    password: {
        type: String,
        min: 8,
        required: [true, 'Preencha sua senha']
    }
});

let UserModel = mongoose.model('UserModel', UserModelSchema);

module.exports = UserModel;
