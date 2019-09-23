class User < ApplicationRecord
  self.primary_key = :id
  has_many :bill_users
  has_many :bills, through: :bill_users
  has_many :owner_bills, class_name: 'Bill'
  has_many :invoice_users
  has_many :invoices, through: :invoice_users
end
