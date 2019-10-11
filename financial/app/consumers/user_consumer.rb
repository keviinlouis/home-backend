class UserConsumer < ApplicationConsumer
  def consume
    send(:"topic_#{topic.name}")
  end

  def topic_user
    user = params.payload

    @user = User.find_or_initialize_by(id: user["id"])

    @user.email = user["email"]
    @user.name = user["name"]

    @user.save
  end
end