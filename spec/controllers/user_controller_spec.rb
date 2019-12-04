require 'rails_helper'

RSpec.describe UserController, type: :controller do
  before(:each) do
    @user = create(:user)
  end
  describe '#login' do
    context 'when credentials are correct' do
      context 'should return user data with token' do
        it 'with new device' do
          expect(Device.count).to eq 0
          post :login, params: { email: @user.email, password: 12345678 }

          send_login email: @user.email, password: 12345678
        end
        it 'with same device' do
          device = @user.device.create
          expect(Device.count).to eq 1
          send_login email: @user.email, password: 12345678, device_id: device.id
        end
      end
    end
  end
  describe '#me' do

  end
  describe '#device' do

  end
  describe '#remove_device' do

  end
  describe '#index' do

  end
  describe '#create' do

  end
  describe '#update' do

  end
  describe '#destroy' do

  end

  private

  def send_login(payload)
    post :login, params: payload

    expect(response).to have_http_status(:success)
    json_response = JSON.parse(response.body)
    expect(json_response.keys).to match_array(%w(id name email token device))
    expect(json_response.keys).not_to match_array(%w(password, created_at, updated_at))
    expect(Device.count).to eq 1
  end
end
