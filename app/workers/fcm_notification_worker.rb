class FcmNotificationWorker
  include Sidekiq::Worker

  def perform(data)
    data = data.transform_keys(&:to_sym)
    notification = Notification.find_by_id data[:id]
    return if notification.blank?
    fcm_api.send_to notification.device_tokens, notification.notification_payload, notification.resource_payload
    notification.sent!
  end

  def fcm_api
    FcmApi.new ENV.fetch('FCM_AUTH_KEY')
  end
end
