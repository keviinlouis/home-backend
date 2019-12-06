require 'rails_helper'

RSpec.describe BillEventController, type: :controller do
  create_user_and_headers

  describe '#index' do
    before(:each) do
      @events_count = 10
      @limit = 5
      @bill = create(:bill, user: @current_user)
      @events = create_list(:bill_event, @events_count, bill: @bill, user: @current_user)
    end

    it 'should list limit size events from bill and from current_user' do
      get :index, params: { bill_id: @bill.id, limit: @limit }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      last_five_bills = @events[5..9].map(&:id)
      response_events_ids = data.map { |event| event["id"].to_i }
      expect(last_five_bills).to match_array response_events_ids
    end

    it 'should list second page events from bill and from current_user' do
      get :index, params: { bill_id: @bill.id, limit: @limit, page: 2 }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      first_five_bills = @events[0..4].map(&:id)
      response_events_ids = data.map { |event| event["id"].to_i }
      expect(first_five_bills).to match_array response_events_ids
    end

    it 'should return not found when bill does not exists' do
      get :index, params: { bill_id: 'wrong_id', limit: @limit }
      expect(response).to have_http_status :not_found
    end

    it 'should return not found when bill does not belongs to current user' do
      bill = create(:bill)
      get :index, params: { bill_id: bill.id, limit: @limit }
      expect(response).to have_http_status :not_found
    end
  end

  describe '#create' do
    before(:each) do
      @bill = create(:bill, user: @current_user)
      @message = 'A nice message'
      expect(BillEvent.count).to eq 0
    end
    it 'should create a event of type message' do
      post :create, params: { bill_id: @bill.id, message: @message }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data["message"]).to eq @message
      expect(BillEvent.count).to eq 1
    end
    it 'should return not found when bill does not exists' do
      post :create, params: { bill_id: 'wrong_id', message: @message }
      expect(response).to have_http_status :not_found
      expect(BillEvent.count).to eq 0
    end

    it 'should return not found when bill does not belongs to current user' do
      bill = create(:bill)
      post :create, params: { bill_id: bill.id, message: @message }
      expect(response).to have_http_status :not_found
      expect(BillEvent.count).to eq 0
    end
  end

  describe '#destroy' do
    before(:each) do
      @bill = create(:bill, user: @current_user)
      @message = 'A nice message'
      @event = create(:bill_event, bill: @bill, user: @current_user)
    end

    it 'should successfully destroy event' do
      delete :destroy, params: { id: @event.id }
      expect(response).to have_http_status :success
    end

    it 'should not destroy event when event does not exists' do
      delete :destroy, params: { id: 'wrong_id' }
      expect(response).to have_http_status :not_found
    end

    it 'should not destroy event when event does not belongs to current_user' do
      event = create(:bill_event)
      delete :destroy, params: { id: event.id }
      expect(response).to have_http_status :not_found
    end
  end

end
