require 'rails_helper'

RSpec.describe FcmNotificationWorker do
  before(:each) do
    @worker = FcmNotificationWorker.new
  end
  describe 'perform' do
    it 'should mark notification as sent' do
      device = create(:device, fcm_token: 'dbSdyGZMens:APA91bH7iemzNbfRjhw6JZ29i9MdsnysZJmxLf_z3Nyw-D8UEHjqaWEsK0In7kcQMhf5rNeecxXZubyEg7JaL-FurFsDtdIzqAIN-NTcKfdSvmxOLzhmiIgcy-sRO_tTTgEv9z7-qs-a')
      notification = create(:notification, user: device.user)
      VCR.use_cassette 'fcm_notification' do
        updated = @worker.perform id: notification.id
        expect(updated).to be_truthy
        expect(notification.reload.status).to eq "sent"
      end
    end

  end
end
