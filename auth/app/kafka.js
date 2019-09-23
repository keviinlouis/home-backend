const Kafka = require('no-kafka');
const producer = new Kafka.Producer({connectionString: process.env.KAFKA_URL, clientId: 'auth'});

const consumer = new Kafka.SimpleConsumer({clientId: 'auth'});

consumer.init().then(() => {
  consumer.subscribe('user',0, function(messageSet, topic, partition){
    console.log(messageSet[0].message.value.toString())
  })
});

module.exports = {producer: producer};
