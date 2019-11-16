class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user, :resource_id, :resource_type, :created_at, :opened, :opened_at

  def user
    UserSerializer.new object.user
  end
end
