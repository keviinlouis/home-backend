class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  after_create :schedule_notification

  enum notification_types: [:bill_added]
  enum status: [:created, :sent, :readed, :error]

  def schedule_notification
    n = Rpush::Gcm::Notification.new
    n.app = Rpush::Gcm::App.find_by_name("fcm_app")
    n.registration_ids = user.device.where('fcm_token is not null').pluck(:fcm_token)
    n.data = { resource: { id: resource.id, type: resource_type }, click_action: "FLUTTER_NOTIFICATION_CLICK" }
    n.priority = 'high'
    n.content_available = true
    n.notification = {
      body: description,
      title: title
    }
    puts n.save!
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
end
