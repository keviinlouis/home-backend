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
      get :show, params: { id: 'wrong_id' }
      expect(response).to have_http_status :not_found
    end

    it 'should return not found when the bill do not belongs to user' do
      new_bill = create(:bill)
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
      @data = {
        name: 'New Bill',
        amount: 15.50
      }
    end
    it 'should create a bill without frequency setup' do
      create_success_bill @data
    end

    it 'should create a bill with frequency setup' do
      @data[:frequency] = 15
      @data[:frequency_type] = "day"

      create_success_bill @data
    end

    it 'should create a bill with description' do
      @data[:frequency] = 15
      @data[:frequency_type] = "day"
      @data[:description] = 'A New bill awesome'

      create_success_bill @data
    end

    context 'with wrong data' do
      it 'should return error when has frequency but frequency_type is empty' do
        @data[:frequency] = 15
        @data[:description] = 'A New bill awesome'
        create_fail_bill @data
      end

      it 'should return error when has frequency_type but frequency is empty' do
        @data[:frequency_type] = "day"
        @data[:description] = 'A New bill awesome'
        create_fail_bill @data
      end

      it 'should return error when expires_at is past' do
        @data[:expires_at] = DateTime.now - 1.day
        create_fail_bill @data
      end
    end
  end
  describe '#update' do
    before(:each) do
      Sidekiq::ScheduledSet.new.clear
      @bill = create(:bill, user: @current_user)

      expect(Sidekiq::ScheduledSet.new.count).to eq 1
      @data = {
        id: @bill.id,
        name: 'New Name',
        amount: @bill.amount + 1,
        description: 'A branch new Description',
        frequency: [*1..30].select { |item| item != @bill.frequency }.sample,
        frequency_type: Bill.frequency_types.keys.select { |item| item != @bill.frequency_type }.sample
      }
    end

    it 'should update all data successfully' do
      @other_user = create(:user)
      users = [
          { id: @other_user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]

      @bill.update_users users
      @bill.active_all_users

      put :update, params: @data
      expect(response).to have_http_status :success
      bill = JSON.parse response.body
      expect(Sidekiq::ScheduledSet.new.count).to eq 1
      @bill.reload
      match_success_bill bill, @data, @current_user

      expect(@bill.name).to eq @data[:name]
      expect(@bill.amount).to eq @data[:amount]
      expect(@bill.frequency).to eq @data[:frequency]
      expect(@bill.frequency_type).to eq @data[:frequency_type]
      expect(@bill.description).to eq @data[:description]
      expect(Notification.count).to eq 1
    end

    it 'should return error when have frequency but frequency_type is blank' do
      @bill = create(:bill_without_frequency, user: @current_user)
      @data.delete(:frequency_type)
      @data[:id] = @bill.id

      put :update, params: @data
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should return error when have frequency_type but frequency is blank' do
      @bill = create(:bill_without_frequency, user: @current_user)
      @data.delete(:frequency)
      @data[:id] = @bill.id

      put :update, params: @data
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should return error when expires_at is in past' do
      @bill.update expires_at: nil
      @data[:expires_at] = DateTime.now - 1.day
      put :update, params: @data
      expect(response).to have_http_status :unprocessable_entity
    end

    it 'should not remove if bill do not belongs to current_user' do
      @bill = create(:bill)
      @data[:id] = @bill.id
      put :update, params: @data
      expect(response).to have_http_status :not_found
    end

    it 'should update invoice user to pending when amount has been updated' do
      @other_user = create(:user)
      users = [
        { id: @other_user.id, percent: 50.0 },
        { id: @current_user.id, percent: 50.0 }
      ]

      @bill.update_users users
      @bill.active_all_users
      invoice_user = @bill.invoices.first.invoice_users.first
      invoice_user.pay(amount: @bill.amount/2)
      expect(invoice_user.paid?).to be_truthy
      put :update, params: @data
      expect(response).to have_http_status :success
      invoice_user.reload
      @bill.reload
      expect(invoice_user.amount).to eq @bill.amount / 2
      expect(invoice_user.pending?).to be_truthy
    end

    it 'should not update invoice user to pending when amount has been updated' do
      @other_user = create(:user)
      users = [
        { id: @other_user.id, percent: 50.0 },
        { id: @current_user.id, percent: 50.0 }
      ]

      @data[:amount] = @bill.amount - 1

      @bill.update_users users
      @bill.active_all_users
      invoice_user = @bill.invoices.first.invoice_users.first
      invoice_user.pay(amount: @bill.amount/2)
      expect(invoice_user.paid?).to be_truthy
      put :update, params: @data
      expect(response).to have_http_status :success
      invoice_user.reload
      @bill.reload
      expect(invoice_user.amount).to eq @bill.amount / 2
      expect(invoice_user.paid?).to be_truthy
    end

    it 'should not update invoice user to pending when invoice is already paid' do
      @other_user = create(:user)
      users = [
        { id: @other_user.id, percent: 50.0 },
        { id: @current_user.id, percent: 50.0 }
      ]

      @data[:amount] = @bill.amount - 1

      @bill.update_users users
      @bill.active_all_users
      @invoice = @bill.invoices.first
      invoice_user = @invoice.invoice_users.first
      another_invoice_user = @invoice.invoice_users.last
      invoice_user.pay(amount: @bill.amount/2)
      another_invoice_user.pay(amount: @bill.amount/2)
      @invoice.paid!
      expect(invoice_user.paid?).to be_truthy
      expect(another_invoice_user.paid?).to be_truthy
      put :update, params: @data
      expect(response).to have_http_status :success
      invoice_user.reload
      another_invoice_user.reload
      @bill.reload
      expect(invoice_user.amount).not_to eq @bill.amount / 2
      expect(invoice_user.paid?).to be_truthy
      expect(another_invoice_user.paid?).to be_truthy
    end
  end

  describe '#destroy' do
    before(:each) do
      Sidekiq::ScheduledSet.new.clear
    end

    it 'should remove bill and all dependents' do
      @bill = create(:bill, user: @current_user)
      delete :destroy, params: { id: @bill.id }
      expect(Bill.count).to eq 0
      expect(Invoice.count).to eq 1
      expect(BillUser.count).to eq 1
      expect(InvoiceUser.count).to eq 1
    end

    it 'should remove not bill when bill do not belongs to current_user' do
      @bill = create(:bill)
      delete :destroy, params: { id: @bill.id }
      expect(Bill.count).to eq 1
      expect(Invoice.count).to eq 1
      expect(BillUser.count).to eq 1
      expect(InvoiceUser.count).to eq 1
    end
  end
  describe '#accept' do
    context 'when current user has been added to bill' do
      before(:each) do
        @bill = create(:bill)
        @bill_users = [
          { id: @bill.user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
        @bill.update_users @bill_users
        @bill.reload
        @bill.bill_users.each do |bill_user|
          bill_user_config = @bill_users.find {|item| item[:id] == bill_user.id}
          expect(bill_user_config).not_to be_nil
          expect(bill_user_config[:percent]).to eq bill_user.next_percent
          expect(bill_user.next_amount).not_to be_nil
        end
      end

      it 'should be able to accept a bill that current user has been added' do
        post :accept, params: { bill_id: @bill.id }
        expect(response).to have_http_status :success

        @bill.reload
        @bill.bill_users.each do |bill_user|
          bill_user_config = @bill_users.find {|item| item[:id] == bill_user.id}
          expect(bill_user_config).not_to be_nil
          expect(bill_user_config[:percent]).to eq bill_user.percent
          expect(bill_user.next_percent).to be_nil
          expect(bill_user.next_amount).to be_nil
        end
        expect(BillEvent.count).to eq 1

      end

      it 'should be able to accept even when current user is already accepted' do
        post :accept, params: { bill_id: @bill.id }
        expect(response).to have_http_status :success

        @bill.reload
        user_ids = [@bill.user.id, @current_user.id]
        @bill.bill_users.each { |bill_user| expect(user_ids).to include bill_user.id }
        expect(BillEvent.count).to eq 1

        post :accept, params: { bill_id: @bill.id }
        expect(response).to have_http_status :success
        expect(BillEvent.count).to eq 1
      end
    end

    it 'should not be able to accept when current user is not added to bill' do
      @bill = create(:bill)
      post :accept, params: { bill_id: @bill.id }
      expect(response).to have_http_status :not_found
      expect(BillEvent.count).to eq 0

      @bill.reload
      user_ids = @bill.bill_users.pluck(:user_id)
      expect(user_ids).not_to include @current_user.id
    end
  end
  describe '#refuse' do
    context 'when current user has been added to bill' do
      before(:each) do
        @bill = create(:bill)
        bill_users = [
          { id: @bill.user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
        @bill.update_users bill_users
      end

      it 'should be able to refuse a bill' do
        post :refuse, params: { bill_id: @bill.id }
        expect(response).to have_http_status :success
        expect(BillEvent.count).to eq 1

        @bill.reload
        user_ids = @bill.bill_users.pluck(:user_id)
        expect(user_ids).not_to include @current_user.id
      end

      it 'should not be able to refuse when current user is already refused' do
        post :refuse, params: { bill_id: @bill.id }
        expect(response).to have_http_status :success
        expect(BillEvent.count).to eq 1

        @bill.reload
        user_ids = @bill.bill_users.pluck(:user_id)
        expect(user_ids).not_to include @current_user.id

        post :refuse, params: { bill_id: @bill.id }
        expect(response).to have_http_status :not_found
        expect(BillEvent.count).to eq 1
      end
    end

    it 'should not be able to refuse when current user is not added to bill' do
      @bill = create(:bill)
      post :accept, params: { bill_id: @bill.id }
      expect(response).to have_http_status :not_found
      expect(BillEvent.count).to eq 0
    end
  end

  private

  def match_bill_response_format(body)
    attributes = %w(id status amount name description frequency frequency_type owner last_invoice expires_at bill_users bill_category)
    attributes.each { |attribute| expect(body.keys).to include(attribute) }
    expect(body.keys).to match_array attributes
  end

  def compare_bill_response(bill, user)
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
    expect(bill_response["bill_users"].count).not_to eq 0
    expect(bill_response["owner"]["id"]).to eq user.id
  end
end
