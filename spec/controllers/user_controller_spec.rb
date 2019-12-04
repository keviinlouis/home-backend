require 'rails_helper'

RSpec.describe UserController, type: :controller do
  create_user_and_headers

  describe '#login' do
    context 'when credentials are correct' do
      context 'should return user data with token' do
        it 'with new device' do
          expect(Device.count).to eq 0
          send_success_login email: @current_user.email, password: 12345678
          expect(Device.count).to eq 1
        end
        it 'with same device' do
          device = @current_user.device.create
          expect(Device.count).to eq 1
          send_success_login email: @current_user.email, password: 12345678, device_id: device.id
          expect(Device.count).to eq 1
        end

        it 'with device that not exists' do
          @current_user.device.create
          expect(Device.count).to eq 1
          send_success_login email: @current_user.email, password: 12345678, device_id: 'wrong_device_id'
          expect(Device.count).to eq 2
        end
      end
    end

    context 'when credentials are incorrect' do
      it 'should return email not found' do
        send_wrong_login email: 'wrong email', password: 12345678
      end
      it 'should return wrong password' do
        send_wrong_login email: @current_user.email, password: 'wrong_password'
      end
    end
  end
  describe '#me' do
    it 'should return user data without token' do
      request.headers.merge! @headers
      get :me
      match_user_response(without_auth: true)
    end
  end
  describe '#device' do
    context 'should update fcm token in device' do
      it 'when the device exists' do
        fcm_token = 'new_fcm_token'
        device = @current_user.device.create
        request.headers.merge! @headers
        put :device, params: { device_id: device.id, token: fcm_token }
        device.reload
        expect(response).to have_http_status(:success)
        expect(device.fcm_token).to eq fcm_token
      end
      it 'when the device not exists' do
        fcm_token = 'new_fcm_token'
        device = @current_user.device.create
        request.headers.merge! @headers
        put :device, params: { device_id: 'wrong_device_id', token: fcm_token }
        device.reload
        expect(response).to have_http_status(:not_found)
        expect(device.fcm_token).to be_nil
      end
    end
  end
  describe '#remove_device' do
    context 'should remove device' do
      it 'when the device exists' do
        device = @current_user.device.create
        request.headers.merge! @headers
        delete :remove_device, params: { device_id: device.id }
        expect(response).to have_http_status(:success)
        expect(Device.find_by(id: device.id)).to be_nil
      end
      it 'when the device not exists' do
        request.headers.merge! @headers
        delete :remove_device, params: { device_id: 'wrong_device_id' }
        expect(response).to have_http_status(:success)
        expect(Device.count).to eq 0
      end
    end
  end
  describe '#index' do
    before(:each) do
      @total_users = 5
      create_list(:user, @total_users)
    end
    it 'should return all users without current user' do
      request.headers.merge! @headers
      get :index
      body_response = JSON.parse(response.body)
      expect(body_response.count).to eq @total_users
      expect(body_response.map { |user| user["id"] }).not_to include(@current_user.id)
    end

    it 'should return all users without current user and excluded users' do
      excluded_user = User.last
      request.headers.merge! @headers
      get :index, params: { exclude: [excluded_user.id] }
      body_response = JSON.parse(response.body)
      expect(body_response.count).to eq @total_users - 1
      expect(body_response.map { |user| user["id"] }).not_to include(@current_user.id)
      expect(body_response.map { |user| user["id"] }).not_to include(excluded_user.id)
    end
  end
  describe '#create' do

  end
  describe '#update' do

  end
  describe '#destroy' do

  end

  private

  def send_success_login(payload)
    post :login, params: payload

    match_user_response
  end

  def send_wrong_login(payload)
    post :login, params: payload

    expect(response).to have_http_status(:unprocessable_entity)
    json_response = JSON.parse(response.body)
    expect(json_response.keys).to match_array(%w(errors))
    expect(json_response.keys).not_to match_array(%w(id name email token device))
    expect(Device.count).to eq 0
    expect(json_response["errors"].count).to eq 1
    json_response
  end

  def match_user_response(options = {})
    expect(response).to have_http_status(:success)
    json_response = JSON.parse(response.body)

    attributes = %w(id name email)

    attributes.push(*%w(token device)) unless options[:without_auth]

    attributes.each { |attribute| expect(json_response.keys).to include(attribute) }

    expect(json_response['id']).to eq @current_user.id
    expect(json_response['name']).to eq @current_user.name
    expect(json_response['email']).to eq @current_user.email
  end
end
