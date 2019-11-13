class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password

  has_many :bill_users
  has_many :bills, through: :bill_users
  has_many :owner_bills, class_name: 'Bill'
  has_many :invoice_users
  has_many :invoices, through: :invoice_users
  has_many :notification

  has_many :device
  has_many :device_with_token, -> { where.not(fcm_token: nil) }

  validates :email, uniqueness: true, presence: true
  validates :name, presence: true


  def token
    payload = { id: id }
    JsonWebToken.encode payload
  end
end
