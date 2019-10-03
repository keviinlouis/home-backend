class BillSerializer < ActiveModel::Serializer
  attributes :id, :status, :amount, :name, :description, :frequency, :frequency_type, :owner, :last_invoice

  belongs_to :bill_category
  has_many :bill_users

  def owner
    UserSerializer.new(object.user)
  end

  def last_invoice
    last_invoice = object.last_invoice
    return nil if last_invoice.nil?
    {
      id: last_invoice.id,
      status: last_invoice.status
    }
  end

  def status
    last_invoice = object.last_invoice
    return nil if last_invoice.nil?
    last_invoice.status
  end
end