const redis = require('async-redis')

module.exports = redis.createClient(process.env.REDIS_URL)
