class BillEventSerializer < ActiveModel::Serializer
  attributes :id, :user, :kind, :message, :info, :readed_by, :created_at, :bill_id

  def user
    UserSerializer.new(object.user)
  end
end
