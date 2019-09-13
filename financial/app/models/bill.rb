class Bill < ApplicationRecord
  belongs_to :user
  belongs_to :bill_category, optional: true
end
