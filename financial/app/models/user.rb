class User < ApplicationRecord
  has_many :bill_users
  has_many :bills, through: :bill_users
  has_many :owner_bills, class_name: 'Bill'
  has_many :invoice_users
  has_many :invoices, through: :invoice_users

  validates_presence_of :auth_id, :name, :email
end
