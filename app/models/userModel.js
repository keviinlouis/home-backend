//Require Mongoose
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const SALT_WORK_FACTOR = 10;

//Define a schema
let UserModelSchema = mongoose.Schema({
    email: {
        type: String,
        unique: [true, 'Este email já existe'],
        required: [true, 'Você precisa de um email'],
        createIndexes: { unique: true },
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


UserModelSchema.pre('save', async function(next) {
    const user = this;

    // only hash the password if it has been modified (or is new)
    if (user.isModified('password')) user.password = await bcrypt.hash(user.password, SALT_WORK_FACTOR);

    next();
});

UserModelSchema.methods.comparePassword = function(candidatePassword) {
    return new Promise((resolve, reject) => {
        bcrypt.compare(candidatePassword, this.password, function(err, isMatch) {
            if (err) return reject(err);
            resolve(isMatch)
        })
    });
};
let UserModel = mongoose.model('UserModel', UserModelSchema);

module.exports = UserModel;
