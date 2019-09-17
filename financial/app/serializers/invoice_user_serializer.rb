class InvoiceUserSerializer < ActiveModel::Serializer
  attributes :id, :amount, :expires_at, :status, :user
  belongs_to :invoice
  belongs_to :user

end
