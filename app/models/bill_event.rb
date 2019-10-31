class BillEvent < ApplicationRecord
  belongs_to :user
  belongs_to :bill

  enum kind: [:message, :event]

  after_create :send_to_kafka

  def send_to_kafka
    serializer = BillEventSerializer.new(self)
    data = serializer.to_h
    data[:notify_users] = bill.bill_users.where.not(user_id: user_id).pluck(:user_id)
  end
end
