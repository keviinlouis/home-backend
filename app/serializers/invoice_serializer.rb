class InvoiceSerializer < ActiveModel::Serializer
  attributes :id, :amount, :expires_at, :status, :created_at

  belongs_to :bill
  has_many :invoice_users
end
