class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  after_create :schedule_notification

  enum notification_types: [:bill_added]
  enum status: [:created, :sent, :readed, :error]

  def schedule_notification

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
