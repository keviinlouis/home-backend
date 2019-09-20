const Kafka = require('no-kafka');
const producer = new Kafka.Producer({connectionString: process.env.KAFKA_URL, clientId: 'auth'});

const consumer = new Kafka.SimpleConsumer({clientId: 'auth'});

consumer.init().then(() => {
  consumer.subscribe('auth',0, function(messageSet, topic, partition){
    console.log(messageSet[0].message.value)
  })
});

module.exports = {producer: producer};
