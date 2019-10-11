class BillEventSerializer < ActiveModel::Serializer
  attributes :id, :user, :kind, :message, :info, :readed_by, :created_at

  def user
    UserSerializer.new(object.user)
  end
end
