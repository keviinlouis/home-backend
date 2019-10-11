# config/initializers/kafka_producer.rb
require "waterdrop"

WaterDrop.setup do |config|
  config.kafka.seed_brokers = [ENV['KAFKA_URL']]
  config.kafka.sasl_plain_username = ENV['KAFKA_USERNAME']
  config.kafka.sasl_plain_password = ENV['KAFKA_PASSWORD']
  config.kafka.sasl_over_ssl = true
  config.kafka.sasl_scram_mechanism = 'sha256'
  config.client_id = 'financial'
  config.logger = Rails.logger
  config.deliver = true
  config.client_id = 'financial'
end