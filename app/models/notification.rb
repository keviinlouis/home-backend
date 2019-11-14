class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  after_create :schedule_notification

  enum notification_types: [:bill_added]
  enum status: [:created, :sent, :readed, :error]

  def schedule_notification
    fcm_api.send_to device_tokens, notification_payload, resource_payload
    update status: :sent
  end

  def read!
    update status: :readed, opened: true, opened_at: DateTime.now
  end

  def self.notify_bill_added(user, bill)
    create(
      title: "Você foi adicionado em uma nova conta",
      description: '',
      user: user,
      resource: bill,
      notification_type: :bill_added
    )
  end

  private

  def device_tokens
    user.device.where('fcm_token is not null').pluck(:fcm_token)
  end

  def notification_payload
    { body: description, title: title }
  end

  def resource_payload
    { id: resource.id, type: resource_type, click_action: "FLUTTER_NOTIFICATION_CLICK" }
  end

  def fcm_api
    FCM.new ENV.fetch('FCM_AUTH_KEY')
  end
end
