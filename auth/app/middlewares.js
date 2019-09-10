const TokenService = require('./services/tokenService');

const auth = async function (req, res, next) {
    const token = req.get('authorization')

    if (!token) {
        return res.status(403).json({error: 'token not provided'})
    }

    const tokenCleared = token.replace('Bearer ', '')

    const isBlackListed = await TokenService.isBlackListed(tokenCleared);

    if(isBlackListed){
        return res.status(401).json({error: 'Sessão Expirada'})
    }

    const isExpired = TokenService.isExpired(tokenCleared);

    if(isExpired){
        res.set('refreshToken', TokenService.refreshTokenAndBlacklist(tokenCleared))
    }

    next()
};

module.exports = {
    auth,
};
