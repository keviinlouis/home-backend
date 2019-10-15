const Kafka = require('no-kafka');
const producer = new Kafka.Producer({connectionString: process.env.KAFKA_URL, clientId: 'auth'});

const consumer = new Kafka.SimpleConsumer({clientId: 'auth'});

consumer.init().then(() => {
  consumer.subscribe('bill_event',0, function(messageSet, topic, partition){
    const billEvent = JSON.parse(messageSet[0].message.value.toString())

    if(billEvent.kind === 'message'){

    }
  })
});

module.exports = {producer: producer};
