class InvoiceUserPaymentSerializer < ActiveModel::Serializer
  attributes :id, :amount, :document_path, :invoice_user
end
