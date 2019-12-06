require 'rails_helper'

RSpec.describe NotificationController, type: :controller do
  create_user_and_headers

  describe '#index' do
    before(:each) do
      @total = 10
      @limit = 5
      @bill = create(:bill, user: @current_user)
      @notifications = create_list(:notification, @total, user: @current_user)
    end

    it 'should list limit size notifications from current_user' do
      get :index, params: { limit: @limit }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      last_five_notifications = @notifications[5..9].map(&:id)
      response_notifications_ids = data.map { |notification| notification["id"].to_i }
      expect(last_five_notifications).to match_array response_notifications_ids
    end

    it 'should list second page notifications from current_user' do
      get :index, params: { limit: @limit, page: 2 }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      first_five_notifications = @notifications[0..4].map(&:id)
      response_notifications_ids = data.map { |notification| notification["id"].to_i }
      expect(first_five_notifications).to match_array response_notifications_ids
    end
  end
  describe '#update' do
    before(:each) do
      @bill = create(:bill, user: @current_user)
      @notification = create(:notification, user: @current_user)
    end

    it 'should able to mark notification as opened' do
      put :update, params: { id: @notification.id }
      expect(response).to have_http_status :success
      expect(@notification.reload.opened?).to be_truthy
    end

    it 'should not able to mark notification as opened when it not exists' do
      put :update, params: { id: 'wrong_id' }
      expect(response).to have_http_status :not_found
      expect(@notification.reload.opened?).to be_falsey
    end

    it 'should not able to mark notification as opened when it not exists' do
      another_notification = create(:notification)

      put :update, params: { id: another_notification.id }
      expect(response).to have_http_status :not_found
      expect(@notification.reload.opened?).to be_falsey
    end
  end
end
