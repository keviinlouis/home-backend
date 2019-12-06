require 'rails_helper'

RSpec.describe BillUserController, type: :controller do
  create_user_and_headers

  describe '#create' do
    before(:each) do
      @bill = create(:bill, user: @current_user)
      @other_user = create(:user)
      @data = {
        bill_id: @bill.id,
        users: [
          { id: @other_user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
      }
      expect(@bill.bill_users.count).to eq 1
    end

    it 'should added users successfully' do
      post :create, params: @data

      expect(response).to have_http_status :success
      @bill.reload
      expect(@bill.bill_users.count).to eq 2
      expect(@bill.bill_users.map(&:next_percent).sum).to eq 100
      expect(BillEvent.count).to eq 1
      expect(Notification.count).to eq 1
    end

    it 'should remove users successfully' do
      post :create, params: @data

      expect(response).to have_http_status :success
      @bill.reload
      @data = {
        bill_id: @bill.id,
        users: [
          { id: @current_user.id, percent: 100.0 }
        ]
      }

      post :create, params: @data

      expect(response).to have_http_status :success

      @bill.reload
      expect(@bill.bill_users.count).to eq 1
      expect(@bill.bill_users.map(&:next_percent).sum).to eq 0
      expect(BillEvent.count).to eq 2
    end

    it 'should return error when total is lower from 100' do
      @data[:users][0][:percent] = 51.0
      post :create, params: @data

      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should return error when total is lower than' do
      @data[:users][0][:percent] = 49.0
      post :create, params: @data

      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should return error when user does not exists' do
      @data[:users][0][:id] = 'wrong_id'
      post :create, params: @data

      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should return not found when bill does not exists' do
      @data[:bill_id] = 'wrong_id'
      post :create, params: @data

      expect(response).to have_http_status :not_found
    end

    it 'should return not found when bill does not belongs to user' do
      @bill = create(:bill)
      @data[:bill_id] = @bill.id
      post :create, params: @data

      expect(response).to have_http_status :not_found
    end
  end
end
