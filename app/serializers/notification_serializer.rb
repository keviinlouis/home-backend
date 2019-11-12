class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :user, :resource_id, :resource_type, :created_at
end
