const Kafka = require('no-kafka');
const producer = new Kafka.Producer({connectionString: process.env.KAFKA_URL, clientId: 'auth'});

const consumer = new Kafka.SimpleConsumer({clientId: 'auth'});

module.exports = {producer: producer, consumer: consumer};
