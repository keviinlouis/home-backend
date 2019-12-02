class FcmNotificationWorker
  include Sidekiq::Worker

  def perform(data)
    puts data
    notification = Notification.find data["id"]
    fcm_api.send_to notification.device_tokens, notification.notification_payload, notification.resource_payload
    notification.update status: :sent
  end

  def fcm_api
    FcmApi.new ENV.fetch('FCM_AUTH_KEY')
  end
end
