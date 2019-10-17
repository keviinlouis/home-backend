# config/initializers/kafka_producer.rb
require "waterdrop"

WaterDrop.setup do |config|
  config.kafka.seed_brokers = [ENV['KAFKA_URL']]
  config.client_id = 'financial'
  config.logger = Rails.logger
end