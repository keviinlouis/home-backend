class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email

  attribute :token, if: :authenticating?
  attribute :device, if: :with_device?

  def authenticating?
    instance_options[:authenticating]
  end

  def device
    device_id = instance_options[:device_id]
    object.device.find(device_id).id
  end

  def with_device?
    instance_options[:device_id]
  end
end
