const { Client } = require('@elastic/elasticsearch');
const elasticsearch = new Client({ node: process.env.ELASTICSEARCH_URL });

module.exports = elasticsearch;