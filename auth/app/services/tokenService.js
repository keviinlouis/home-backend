const jwt = require('jsonwebtoken');
const redisClient = require('../redis');

const secret = process.env.JWT_SECRET;
const ttl = process.env.JWT_TTL;

class TokenService {
    static sign(payload) {
        return jwt.sign(payload, secret, {expiresIn: ttl})
    }

    static decode(token){
        return jwt.decode(token)
    }

    static isExpired(token) {
        const payload = jwt.decode(token);
        const expirationDate = new Date(payload.exp * 1000);
        const now = new Date();

        return expirationDate < now
    }

    static async isBlackListed(token) {
        const lengthOfBlackListedTokens = await redisClient.llen('blackListedTokens');
        const blackListedTokens = await redisClient.lrange('blackListedTokens', 0, lengthOfBlackListedTokens);
        return blackListedTokens.indexOf(token) > -1
    }

    static refreshTokenAndBlacklist(token) {
        const payload = jwt.decode(token);
        delete payload.exp;
        delete payload.iat;
        const newToken = TokenService.sign(payload);
        TokenService.blackListToken(token);
        return newToken
    }

    static blackListToken(token) {
        redisClient.lpush('blackListedTokens', token)
    }
}

module.exports = TokenService;
