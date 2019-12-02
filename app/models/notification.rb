class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  after_save :schedule_notification, if: :sendable?

  enum notification_types: [:bill_added, :bill_updated, :bill_refused, :bill_accepted]
  enum status: [:created, :sent, :readed, :error]

  def schedule_notification
    FcmNotificationWorker.perform_async id: id
  end

  def read!
    update status: :readed, opened: true, opened_at: DateTime.now
  end

  def self.notify_bill_added(user, bill)
    first_name = bill.user.name.split(' ').first

    data = {
      title: "#{first_name} te adionou em uma nova conta",
      description: '',
      notification_type: :bill_added,
    }

    notify user, bill, data
  end

  def self.notify_bill_edited(user, bill)
    first_name = bill.user.name.split(' ').first

    data = {
      title: "#{first_name} editou a conta de #{bill.name}",
      description: '',
      notification_type: :bill_updated,
    }

    notify user, bill, data
  end

  def self.notify_user_accept_bill(bill, user)
    first_name = user.name.split(' ').first

    data = {
      title: "#{first_name} aceitou a conta de #{bill.name}",
      description: '',
      notification_type: :bill_accepted,
    }

    notify bill.user, bill, data
  end

  def self.notify_user_refused_bill(bill, user)
    first_name = user.name.split(' ').first

    data = {
      title: "#{first_name} recusou a conta de #{bill.name}",
      description: '',
      notification_type: :bill_refused,
    }

    notify bill.user, bill, data
  end

  def self.notify(user, resource, data)
    notification = self.where(resource_id: resource.id, resource_type: resource.class.to_s, user_id: user.id, opened: false).first

    notification = self.new unless notification

    default_data = {
      resource: resource,
      user_id: user.id,
      opened: false,
      status: :created,
    }

    notification.attributes = data.merge(default_data)

    notification.save
  end

  def sendable?
    !opened? && !readed? && created?
  end

  def device_tokens
    user.device.where('fcm_token is not null').pluck(:fcm_token)
  end

  def notification_payload
    { body: description, title: title }
  end

  def resource_payload
    { id: resource.id, type: resource_type, click_action: "FLUTTER_NOTIFICATION_CLICK" }
  end
end
