//Require Mongoose
const {Schema, model} = require('mongoose');
const mongooseDelete = require('mongoose-delete');
const bcrypt = require('bcrypt');
const {validateEmail} = require('../validations');
const TokenService = require('../services/tokenService');
const elasticsearch = require('../elasticsearch');
const SALT_WORK_FACTOR = 10;

const schema = {
    email: {
        type: String,
        trim: true,
        lowercase: true,
        unique: [true, 'Este email já existe'],
        required: 'Você precisa de um email',
        validate: [validateEmail, 'Este email é inválido'],
    },
    name: {
        type: String,
        minlength: [5, 'Esse nome está muito curto'],
        required: [true, 'Precisamos te chamar por algum nome né?']
    },
    password: {
        type: String,
        minlength: [8, 'Sua senha precisa de 8 caracteres'],
        required: [true, 'Preencha sua senha']
    },
};

const options = {
    timestamps: true
};

//Define a schema
let UserModelSchema = Schema(schema, options);

UserModelSchema.plugin(mongooseDelete, { deletedAt: true, overrideMethods: true });

UserModelSchema.pre('save', async function (next) {
    const user = this;

    if (user.isModified('password')) user.password = await bcrypt.hash(user.password, SALT_WORK_FACTOR);

    next();
});

UserModelSchema.post('save', async function(user, next){
    await elasticsearch.index({
        index: 'users',
        id: user._id,
        body: {
            name: user.name,
            email: user.email
        }
    });
    next();
});

UserModelSchema.methods.comparePassword = function (candidatePassword) {
    return new Promise((resolve, reject) => {
        bcrypt.compare(candidatePassword, this.password, function (err, isMatch) {
            if (err) return reject(err);
            resolve(isMatch)
        })
    });
};

UserModelSchema.methods.generateToken = function () {
    const payload = {id: this._id};
    return TokenService.sign(payload)
};

UserModelSchema.methods.toResponse = function (withToken = false) {
    const user = this;
    const data = {
        id: user._id,
        email: user.email,
        name: user.name,
    };

    if (withToken) {
        data.token = user.generateToken()
    }
    return data
};

UserModelSchema.statics.findByToken = function (token) {
    if (!token) return;
    const payload = TokenService.decode(token);
    if (!payload || !payload.id) return;
    return this.findById(payload.id)
};

const UserModel = model('UserModel', UserModelSchema);

module.exports = UserModel;
