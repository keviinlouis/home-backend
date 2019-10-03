class BillUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :amount, :percent, :next_percent, :status, :last_invoice

  def id
    object.user_id
  end

  def name
    object.user.name
  end

  def email
    object.user.email
  end
end
