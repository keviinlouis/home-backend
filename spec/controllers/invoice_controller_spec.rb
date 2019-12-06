require 'rails_helper'

RSpec.describe InvoiceController, type: :controller do
  create_user_and_headers

  describe "#index" do
    before(:each) do
      @invoice_count = 10
      @limit = 5
      @bills = create_list(:bill, @invoice_count, user: @current_user)
      @invoices = @bills.map(&:last_invoice)
    end
    context 'with status as parameter' do
      it 'should list limit size invoice from current_user' do
        get :index, params: { limit: @limit, status: :available }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq @limit
        first_five_invoices = @invoices[0..4].map(&:id)
        response_invoices_ids = data.map { |invoice| invoice["id"].to_i }
        expect(first_five_invoices).to match_array response_invoices_ids
      end

      it 'should list second page invoice from current_user' do
        get :index, params: { limit: @limit, status: :available }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq @limit
        first_five_invoices = @invoices[0..4].map(&:id)
        response_invoices_ids = data.map { |invoice| invoice["id"].to_i }
        expect(first_five_invoices).to match_array response_invoices_ids
      end

      it 'should return a empty list when there no invoice with status' do
        get :index, params: { limit: @limit, status: :expired }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq 0
      end

      it 'should return a list when status do not exits' do
        get :index, params: { limit: @limit, status: 'wrong_status' }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq @limit
      end
    end

    context 'without status as parameter' do
      it 'should list limit size invoice from current_user' do
        get :index, params: { limit: @limit }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq @limit
        first_five_invoices = @invoices[0..4].map(&:id)
        response_invoices_ids = data.map { |invoice| invoice["id"].to_i }
        expect(first_five_invoices).to match_array response_invoices_ids
      end

      it 'should list second page invoice from current_user' do
        get :index, params: { limit: @limit }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq @limit
        first_five_invoices = @invoices[0..4].map(&:id)
        response_invoices_ids = data.map { |invoice| invoice["id"].to_i }
        expect(first_five_invoices).to match_array response_invoices_ids
      end
    end

    context 'with bill as parameter' do
      it 'should list invoice from current_user' do
        get :index, params: { limit: @limit, bill: @bills.first.id }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq 1
        first_invoices = data.first
        expect(first_invoices["bill"]["id"]).to eq @bills.first.id
      end

      it 'should return a empty list invoice when bill do not belong to current user' do
        bill = create(:bill)
        get :index, params: { limit: @limit, bill: bill.id }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq 0
      end

      it 'should return a empty list invoice when bill do not exists' do
        get :index, params: { limit: @limit, bill: 'wrong_id' }
        expect(response).to have_http_status :success
        data = JSON.parse response.body
        expect(data.count).to eq 0
      end
    end
  end

  describe "#show" do
    before(:each) do
      @bill = create(:bill, user: @current_user)
      @invoice = @bill.last_invoice
    end
    it 'should return a invoice' do
      get :show, params: { id: @invoice.id }
      expect(response).to have_http_status :success
      invoice = JSON.parse response.body
      expect(invoice["id"]).to eq @invoice.id
      expect(invoice["amount"]).to eq @invoice.amount
      expect(invoice["status"]).to eq @invoice.status.to_s
      expect(invoice["bill"]["id"]).to eq @bill.id
    end

    it 'should return a not found error when invoice does not exists' do
      get :show, params: { id: 'wrong_id' }
      expect(response).to have_http_status :not_found
    end

    it 'should return a not found error when invoice does not belong to current_user' do
      @bill = create(:bill)
      @invoice = @bill.last_invoice
      get :show, params: { id: @invoice.id }
      expect(response).to have_http_status :not_found
    end
  end
end
