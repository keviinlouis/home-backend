require 'rails_helper'

RSpec.describe BillController, type: :controller do
  create_user_and_headers

  describe '#index' do
    before(:each) do
      @bill_count = 10
      @limit = 5
      @bills = create_list(:bill, @bill_count, user: @current_user)
    end

    it 'should list limit size bills from current_user' do
      request.headers.merge! @headers
      get :index, params: { limit: @limit }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      data.each(&method(:match_bill_response_format))
      first_five_bills = @bills[0..4].map(&:id)
      response_bills_ids = data.map { |bill| bill["id"].to_i }
      expect(first_five_bills).to match_array response_bills_ids
    end

    it 'should list second page bills from current_user' do
      request.headers.merge! @headers
      get :index, params: { limit: @limit, page: 2 }
      expect(response).to have_http_status :success
      data = JSON.parse response.body
      expect(data.count).to eq @limit
      data.each(&method(:match_bill_response_format))
      first_five_bills = @bills[5..9].map(&:id)
      response_bills_ids = data.map { |bill| bill["id"].to_i }
      expect(first_five_bills).to match_array response_bills_ids
    end
  end

  describe '#show' do
    before(:each) do
      @bill = create(:bill, user: @current_user)
    end
    it 'should show attributes for bill' do
      compare_bill_response @bill, @current_user
    end
    it 'should return not found when the bill do not exists' do
      request.headers.merge! @headers
      get :show, params: { id: 'wrong_id' }
      expect(response).to have_http_status :not_found
    end

    it 'should return not found when the bill do not belongs to user' do
      new_bill = create(:bill)
      request.headers.merge! @headers
      get :show, params: { id: new_bill.id }
      expect(response).to have_http_status :not_found
    end

    it 'should return bill even when the current_user is not the owner' do
      new_bill = create(:bill)
      bill_users = [
        { id: new_bill.user.id, percent: 50.0 },
        { id: @current_user.id, percent: 50.0 }
      ]
      new_bill.update_users bill_users
      compare_bill_response new_bill, new_bill.user
    end
  end

  describe '#create' do
    before(:each) do
      Sidekiq::ScheduledSet.new.clear
    end
    it 'should create a bill without frequency setup' do
      data = {
        name: 'New Bill',
        amount: 15.50
      }

      create_success_bill data
    end

    it 'should create a bill with frequency setup' do
      data = {
        name: 'New Bill',
        amount: 15.50,
        frequency: 15,
        frequency_type: "day"
      }

      create_success_bill data
    end

    it 'should create a bill with description' do
      data = {
        name: 'New Bill',
        amount: 15.50,
        frequency: 15,
        frequency_type: "day",
        description: 'A New bill awesome'
      }

      create_success_bill data
    end

    context 'with wrong data' do
      it 'should return error when has frequency but frequency_type is empty' do
        data = {
          name: 'New Bill',
          amount: 15.50,
          frequency: 15,
          description: 'A New bill awesome'
        }
        create_fail_bill data
      end

      it 'should return error when has frequency_type but frequency is empty' do
        data = {
          name: 'New Bill',
          amount: 15.50,
          frequency_type: "days",
          description: 'A New bill awesome'
        }
        create_fail_bill data
      end

      it 'should return error when expires_at is past' do
        data = {
          name: 'New Bill',
          amount: 15.50,
          expires_at: DateTime.now - 1.day
        }

        create_fail_bill data
      end
    end
  end
  describe '#update' do
    before(:each) do
      Sidekiq::ScheduledSet.new.clear
      @bill = create(:bill, user: @current_user)
    end

    it 'should update all data successfully' do
      expect(Sidekiq::ScheduledSet.new.count).to eq 1
      data = {
        id: @bill.id,
        name: 'New Name',
        amount: @bill.amount + 1,
        description: 'A branch new Description',
        frequency: [*1..30].select { |item| item != @bill.frequency }.sample,
        frequency_type: Bill.frequency_types.keys.select { |item| item != @bill.frequency_type }.sample
      }


      request.headers.merge! @headers
      put :update, params: data
      expect(response).to have_http_status :success
      bill = JSON.parse response.body
      expect(Sidekiq::ScheduledSet.new.count).to eq 1
      @bill.reload
      match_success_bill bill, data, @current_user

      expect(@bill.name).to eq data[:name]
      expect(@bill.amount).to eq data[:amount]
      expect(@bill.frequency).to eq data[:frequency]
      expect(@bill.frequency_type).to eq data[:frequency_type]
      expect(@bill.description).to eq data[:description]
    end
  end
  describe '#destroy' do

  end
  describe '#accept' do

  end
  describe '#refuse' do

  end

  private

  def match_bill_response_format(body)
    attributes = %w(id status amount name description frequency frequency_type owner last_invoice expires_at bill_users bill_category)
    attributes.each { |attribute| expect(body.keys).to include(attribute) }
    expect(body.keys).to match_array attributes
  end

  def compare_bill_response(bill, user)
    request.headers.merge! @headers
    get :show, params: { id: bill.id }
    expect(response).to have_http_status :success
    bill_response = JSON.parse response.body
    match_bill_response_format bill_response
    expect(bill_response["id"]).to eq bill.id
    expect(bill_response["amount"]).to eq bill.amount
    expect(bill_response["name"]).to eq bill.name
    expect(bill_response["description"]).to eq bill.description
    expect(bill_response["expires_at"]).to eq bill.expires_at.to_s
    expect(bill_response["frequency"]).to eq bill.frequency
    expect(bill_response["frequency_type"]).to eq bill.frequency_type
    expect(bill_response["owner"]["id"]).to eq user.id
  end

  def create_success_bill(data)
    request.headers.merge! @headers
    post :create, params: data
    expect(response).to have_http_status :success
    expect(Bill.count).to eq 1
    expect(BillUser.count).to eq 1
    expect(BillEvent.count).to eq 1
    expect(Invoice.count).to eq 1
    expect(InvoiceUser.count).to eq 1
    expect(Sidekiq::ScheduledSet.new.count).to eq 1 if data[:frequency].present?
    bill = JSON.parse response.body
    match_success_bill(bill, data, @current_user)
  end

  def create_fail_bill(data)
    request.headers.merge! @headers
    post :create, params: data

    expect(response).to have_http_status(:unprocessable_entity)
    json_response = JSON.parse(response.body)
    expect(json_response.keys).to match_array(%w(errors))
    expect(json_response["errors"].count).to eq 1
    expect(Bill.count).to eq 0
    expect(BillUser.count).to eq 0
    expect(Invoice.count).to eq 0
    expect(InvoiceUser.count).to eq 0
    expect(Sidekiq::ScheduledSet.new.count).to eq 0
  end

  def match_success_bill(bill_response, data, user)
    expect(bill_response["name"]).to eq data[:name]
    expect(bill_response["amount"]).to eq data[:amount]
    expect(bill_response["frequency"]).to eq data[:frequency]
    expect(bill_response["frequency_type"]).to eq data[:frequency_type]
    expect(bill_response["description"]).to eq data[:description]
    expect(bill_response["last_invoice"]).not_to be_nil
    expect(bill_response["last_invoice"]["status"]).to eq "available"
    expect(bill_response["bill_users"].count).to eq 1
    expect(bill_response["owner"]["id"]).to eq user.id
    first_bill_user = bill_response["bill_users"].first
    expect(first_bill_user["id"]).to eq user.id
    expect(first_bill_user["amount"]).to eq data[:amount]
    expect(first_bill_user["percent"]).to eq 100
    expect(first_bill_user["next_amount"]).to be_nil
    expect(first_bill_user["next_percent"]).to be_nil
    expect(first_bill_user["last_invoice"]).not_to be_nil
    expect(first_bill_user["last_invoice"]["status"]).to eq "available"
    expect(first_bill_user["last_invoice"]["amount"]).to eq data[:amount]
  end
end
