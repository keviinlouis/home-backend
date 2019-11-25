class InvoiceUserSerializer < ActiveModel::Serializer
  attributes :id, :amount, :expires_at, :status, :user, :total_payed
  belongs_to :invoice
  belongs_to :user

  def user
    UserSerializer.new object.user
  end

end
