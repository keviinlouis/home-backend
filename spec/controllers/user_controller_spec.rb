require 'rails_helper'

RSpec.describe UserController, type: :controller do
  create_user_and_headers

  describe "#load_user" do
    it "should return a loaded user" do
      get :me
      expect(response).to have_http_status :success
    end

    it "should return a expired token error" do
      payload = { id: @current_user.id }
      expired_token = JsonWebToken.encode payload, DateTime.now - 1.day
      @headers = { authorization: "Bearer #{expired_token}" }
      request.headers.merge! @headers
      get :me
      expect(response).to have_http_status :unauthorized
    end

    it "should return a decoded error when token is not sent" do
      @headers = { authorization: nil }
      request.headers.merge! @headers
      get :me
      expect(response).to have_http_status :unauthorized
    end

    it "should return a not found user" do
      payload = { id: 'wrong_id' }
      expired_token = JsonWebToken.encode payload, DateTime.now - 1.day
      @headers = { authorization: "Bearer #{expired_token}" }
      request.headers.merge! @headers
      get :me
      expect(response).to have_http_status :unauthorized
    end
  end

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
      get :me
      match_user_response(without_auth: true)
    end
  end
  describe '#device' do
    context 'should update fcm token in device' do
      it 'when the device exists' do
        fcm_token = 'new_fcm_token'
        device = @current_user.device.create
        put :device, params: { device_id: device.id, token: fcm_token }
        device.reload
        expect(response).to have_http_status(:success)
        expect(device.fcm_token).to eq fcm_token
      end
      it 'when the device not exists' do
        fcm_token = 'new_fcm_token'
        device = @current_user.device.create
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
        delete :remove_device, params: { device_id: device.id }
        expect(response).to have_http_status(:success)
        expect(Device.find_by(id: device.id)).to be_nil
      end
      it 'when the device not exists' do
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
      get :index
      body_response = JSON.parse(response.body)
      expect(body_response.count).to eq @total_users
      expect(body_response.map { |user| user["id"] }).not_to include(@current_user.id)
    end

    it 'should return all users without current user and excluded users' do
      excluded_user = User.last
      get :index, params: { exclude: [excluded_user.id] }
      body_response = JSON.parse(response.body)
      expect(body_response.count).to eq @total_users - 1
      expect(body_response.map { |user| user["id"] }).not_to include(@current_user.id)
      expect(body_response.map { |user| user["id"] }).not_to include(excluded_user.id)
    end
  end
  describe '#create' do
    it 'should return new user with new device' do
      password = '12345678'
      user = build(:user)
      expect(User.count).to eq 1
      post :create, params: { name: user.name, email: user.email, password: password }

      expect(response).to have_http_status(:success)

      expect(User.count).to eq 2
      expect(Device.count).to eq 1
      json_response = JSON.parse(response.body)

      attributes = %w(id name email token device)

      attributes.each { |attribute| expect(json_response.keys).to include(attribute) }

      expect(json_response['name']).to eq user.name
      expect(json_response['email']).to eq user.email

      device_id = json_response['device']

      post :login, params: {email: user.email, password: password, device_id: device_id}

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)

      attributes = %w(id name email token device)

      attributes.each { |attribute| expect(json_response.keys).to include(attribute) }

      expect(json_response['name']).to eq user.name
      expect(json_response['email']).to eq user.email
      expect(json_response['device']).to eq device_id
    end
    context 'with wrong data' do
      before(:all) do
        @password = '12345678'
      end
      it 'should return email already exists' do

        user = build(:user)
        user.email = @current_user.email
        send_wrong_create name: user.name, email: user.email, password: @password
      end
      it 'should return missing email field' do
        user = build(:user)
        send_wrong_create name: user.name, password: @password
      end

      it 'should return missing name field' do
        user = build(:user)
        send_wrong_create email: user.email, password: @password
      end

      it 'should return missing password field' do
        user = build(:user)
        send_wrong_create name: user.name,  email: user.email
      end
    end
  end
  describe '#update' do
    it 'should update user data' do
      new_name = 'new name'
      new_email = 'new@mail.com'
      put :update, params: { name: new_name, email: new_email }
      @current_user.reload
      match_user_response(without_auth: true)
      expect(new_name).to eq @current_user.name
      expect(new_email).to eq @current_user.email
    end

    it 'should update user data even when is same email' do
      new_name = 'new name'
      new_email = @current_user.email
      put :update, params: { name: new_name, email: new_email }
      @current_user.reload
      match_user_response(without_auth: true)
      expect(new_name).to eq @current_user.name
      expect(new_email).to eq @current_user.email
    end

    it 'should return email exists' do
      other_user = create(:user)
      old_email = @current_user.reload.email
      new_name = 'new name'
      new_email = other_user.email
      put :update, params: { name: new_name, email: new_email }
      expect(response).to have_http_status(:unprocessable_entity)
      json_response = JSON.parse(response.body)
      expect(json_response.keys).to match_array(%w(errors))
      @current_user.reload
      expect(old_email).to eq @current_user.email

    end

    context 'when trying to update password' do
      it 'should return update password' do
        new_password = 'new_password'
        put :update, params: { password: new_password, password_confirmation: new_password }
        expect(response).to have_http_status(:success)
        match_user_response(without_auth: true)
        post :login, params: {email: @current_user.email, password: new_password}
        expect(response).to have_http_status(:success)
      end

      it 'should return password dont match' do
        new_password = 'new_password'
        put :update, params: { password: new_password, password_confirmation: 'wrong_password_confirmation' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#destroy' do
    it 'should delete user' do
      delete :destroy
      expect(response).to have_http_status(:success)
      expect(User.count).to eq 0
      # TODO Check if bills are deleted
    end
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

  def send_wrong_create(payload)
    expect(User.count).to eq 1
    post :create, params: payload

    expect(response).to have_http_status(:unprocessable_entity)
    json_response = JSON.parse(response.body)
    expect(json_response.keys).to match_array(%w(errors))
    expect(json_response.keys).not_to match_array(%w(id name email token device))
    expect(Device.count).to eq 0
    expect(User.count).to eq 1
    expect(json_response["errors"].count).to eq 1
  end
end
