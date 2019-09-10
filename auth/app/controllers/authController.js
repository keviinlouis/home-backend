const UserModel = require('../models/userModel');
const TokenService = require('../services/tokenService')

exports.login = async (req, res) => {
    const {email, password} = req.body;

    const user = await UserModel.findOne({email});

    if (!user) {
        return res.status(404).json({error: 'NOT_FOUNDED'})
    }
    // test a matching password
    const isMatch = await user.comparePassword(password);

    if (!isMatch) {
        return res.status(401).json({error: 'WRONG_PASSWORD'});
    }

    res.status(200).json(user.toResponse(true));
};

exports.signIn = async (req, res) => {
    const {email, name, password} = req.body;

    const user = new UserModel({email, name, password});

    const userSaved = await user.save();

    res.status(201).json(userSaved.toResponse(true));
};

exports.validateToken = async (req, res) => {
    const {token} = req.body;

    const isBlackListed = await TokenService.isBlackListed(token);

    if(isBlackListed){
        return res.status(401).json({error: 'Sessão Expirada'})
    }

    const user = await UserModel.findByToken(token);

    if(!user){
        return res.status(404).json({error: 'Usuário não encontrado'})
    }

    const isExpired = TokenService.isExpired(token);

    if(isExpired){
        res.set('refreshToken', TokenService.refreshTokenAndBlacklist(token))
    }

    return res.status(201).json(user.toResponse());
};

