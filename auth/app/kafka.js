const Kafka = require('no-kafka');
const kafkaProducer = new Kafka.Producer({connectionString: process.env.KAFKA_URL});

module.exports = {producer: kafkaProducer};
