class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email

  attribute :token, if: :authenticating?

  def authenticating?
    instance_options[:generate_token]
  end
end
