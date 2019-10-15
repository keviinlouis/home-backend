class BillEvent < ApplicationRecord
  belongs_to :user
  belongs_to :bill

  enum kind: [:message, :event]

  before_create :send_to_kafka

  def send_to_kafka
    serializer = BillEventSerializer.new(self)
    WaterDrop::AsyncProducer.call(serializer.to_json, topic: 'bill_event')
  end
end
