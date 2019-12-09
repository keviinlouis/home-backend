require 'rails_helper'

RSpec.describe FcmApi do
  before(:each) do
    @api = FcmApi.new ENV.fetch('FCM_AUTH_KEY')
  end
  describe '#send_to' do
    it 'should send with string' do
      device = create(:device, fcm_token: 'dbSdyGZMens:APA91bH7iemzNbfRjhw6JZ29i9MdsnysZJmxLf_z3Nyw-D8UEHjqaWEsK0In7kcQMhf5rNeecxXZubyEg7JaL-FurFsDtdIzqAIN-NTcKfdSvmxOLzhmiIgcy-sRO_tTTgEv9z7-qs-a')
      notification = create(:notification, user: device.user)

      VCR.use_cassette 'fcm_notification' do
        response = @api.send_to device.fcm_token, notification.notification_payload, notification.resource_payload
        expect(response["success"]).to eq 1
        expect(response["failure"]).to eq 0
      end
    end
  end
end
