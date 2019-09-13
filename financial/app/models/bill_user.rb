class BillUser < ApplicationRecord
  belongs_to :user
  belongs_to :bill
end
