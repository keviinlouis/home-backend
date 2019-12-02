class InvoiceUserPaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :invoice_user, :image_url
end
