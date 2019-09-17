class BillUserSerializer < ActiveModel::Serializer
  attributes :id, :amount, :percent, :next_percent, :status, :user

  def user
    UserSerializer.new(object.user)
  end
end
