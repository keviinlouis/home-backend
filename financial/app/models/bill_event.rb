class BillEvent < ApplicationRecord
  belongs_to :user
  belongs_to :bill

  enum kind: [:message, :event]
end
