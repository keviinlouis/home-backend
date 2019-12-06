require 'rails_helper'

RSpec.describe InvoiceUserPaymentController, type: :controller do
  create_user_and_headers
  before(:each) do
    @bill = create(:bill, amount: 99, user: @current_user)
    @invoice = @bill.invoices.first
    @invoice_user = @invoice.invoice_users.first
    expect(InvoiceUserPayment.count).to eq 0
  end

  describe '#index' do
    context 'when user is trying to see your payments' do
      before(:each) do
        @total_payments = 3
        @invoice_user_payments = create_list(
          :invoice_user_payment,
          @total_payments,
          invoice_user: @invoice_user,
          amount: @invoice_user.amount / @total_payments
        )
      end

      it 'should list all payments from invoice user' do
        get :index, params: { invoice_user_id: @invoice_user.id }
        expect(response).to have_http_status :success
        payments = JSON.parse response.body
        expect(payments.count).to eq @total_payments
      end

      it 'should list all payments from invoice user event when does not belongs to current user' do
        another_user = create(:user)
        users = [
          { id: another_user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
        @bill.update_users users
        @bill.active_all_users
        another_invoice_user = @bill.invoices.reload.last.invoice_users.where(user_id: another_user.id).first
        @invoice_user_payments = create_list(
          :invoice_user_payment,
          @total_payments,
          invoice_user: another_invoice_user,
          amount: another_invoice_user.amount / @total_payments
        )
        get :index, params: { invoice_user_id: another_invoice_user.id }
        expect(response).to have_http_status :success
        payments = JSON.parse response.body
        expect(payments.count).to eq @total_payments
      end

      it 'should list empty payments when invoice user does not exists' do
        get :index, params: { invoice_user_id: 'wrong_id' }
        expect(response).to have_http_status :not_found
      end

      it 'should list empty payments when current user does not belongs to bill of invoice user' do
        get :index, params: { invoice_user_id: 'wrong_id' }
        expect(response).to have_http_status :not_found
      end
    end

  end
  describe '#create' do
    context 'when current user wants to pay a invoice' do
      it 'should be able to pay with only amount' do
        data = {
          invoice_user_id: @invoice_user.id,
          amount: @invoice_user.amount
        }
        post :create, params: data
        expect(response).to have_http_status :success
        @invoice.reload
        @invoice_user.reload
        expect(@invoice_user.status).to eq "paid"
        expect(@invoice.status).to eq "paid"
        expect(InvoiceUserPayment.count).to eq 1
      end

      it 'should be able to pay with file' do
        image = fixture_file_upload('files/image.png', 'image/png')
        data = {
          invoice_user_id: @invoice_user.id,
          amount: @invoice_user.amount,
          image: image
        }
        post :create, params: data
        expect(response).to have_http_status :success
        @invoice.reload
        @invoice_user.reload
        expect(@invoice_user.status).to eq "paid"
        expect(@invoice.status).to eq "paid"
        expect(InvoiceUserPayment.count).to eq 1
        expect(@invoice_user.invoice_user_payment.first.image_url).not_to be_nil
      end

      it 'should be able to pay multiple times until reach amount' do
        image = fixture_file_upload('files/image.png', 'image/png')
        times_to_pay = 3
        times_to_pay.times do |current_time|
          data = {
            invoice_user_id: @invoice_user.id,
            amount: @invoice_user.amount / times_to_pay,
            image: image
          }
          post :create, params: data
          expect(response).to have_http_status :success
          unless times_to_pay == current_time + 1
            @invoice_user.reload
            expect(@invoice_user.status).to eq "pending"
          end
        end

        @invoice.reload
        @invoice_user.reload
        expect(@invoice_user.status).to eq "paid"
        expect(@invoice.status).to eq "paid"
        expect(InvoiceUserPayment.count).to eq times_to_pay
      end


      it 'should be able to pay wen amount is less or equal to zero' do
        data = {
          invoice_user_id: @invoice_user.id,
          amount: 0
        }
        post :create, params: data
        expect(response).to have_http_status :unprocessable_entity

        data = {
          invoice_user_id: @invoice_user.id,
          amount: -1
        }
        post :create, params: data
        expect(response).to have_http_status :unprocessable_entity
      end

      it 'should not be able to pay when invoice user does not exists' do
        data = {
          invoice_user_id: 'wrong_invoice_user_id',
          amount: @invoice_user.amount
        }
        post :create, params: data
        expect(response).to have_http_status :not_found
        expect(InvoiceUserPayment.count).to eq 0
      end

      it 'should not be able to pay when invoice user does not belongs to user' do
        @bill = create(:bill)
        @invoice = @bill.invoices.first
        @invoice_user = @invoice.invoice_users.first
        data = {
          invoice_user_id: @invoice_user.id,
          amount: @invoice_user.amount
        }
        post :create, params: data
        expect(response).to have_http_status :forbidden
        expect(InvoiceUserPayment.count).to eq 0
      end
    end

  end
  describe '#destroy' do
    context 'when has one payment' do
      before(:each) do
        @total_payments = 3
        another_user = create(:user)
        users = [
          { id: another_user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
        @bill.update_users users
        @bill.active_all_users
        @invoice = @bill.invoices.reload.last
        @another_invoice_user = @invoice.invoice_users.where(user_id: another_user.id).first
        @invoice_user_payment = create(
          :invoice_user_payment,
          invoice_user: @invoice_user,
          amount: @invoice_user.amount
        )

        @invoice_user.update status: :paid
      end

      it 'should be able to delete a payment' do
        @invoice.paid!
        delete :destroy, params: { id: @invoice_user_payment.id }
        expect(@invoice_user.reload.status).to eq "available"
        expect(@invoice.reload.status).to eq "available"
      end

      it 'should not be able to delete a payment when invoice has been paid' do
        create(
          :invoice_user_payment,
          invoice_user: @another_invoice_user,
          amount: @invoice_user.amount
        )
        @another_invoice_user.update status: :paid
        @invoice.paid!
        delete :destroy, params: { id: @invoice_user_payment.id }
        expect(response).to have_http_status :unprocessable_entity
        expect(@invoice_user.reload.status).to eq "paid"
        expect(@invoice.reload.status).to eq "paid"
      end
    end

    context 'when has multiple payments' do
      before(:each) do
        @total_payments = 3
        @invoice_user_payments = create_list(
          :invoice_user_payment,
          @total_payments,
          invoice_user: @invoice_user,
          amount: @invoice_user.amount / @total_payments
        )
      end

      it 'should be able to delete a payment' do
        payment_to_delete = @invoice_user_payments.first
        delete :destroy, params: { id: payment_to_delete.id }
        @invoice_user.reload
        expect(@invoice_user.invoice_user_payment.count).to eq 2
        expect(@invoice_user.status).to eq "pending"
      end
    end

    context 'when payments does not belongs to current_user' do
      before(:each) do
        @total_payments = 3
        another_user = create(:user)
        users = [
          { id: another_user.id, percent: 50.0 },
          { id: @current_user.id, percent: 50.0 }
        ]
        @bill.update_users users
        @bill.active_all_users
        another_invoice_user = @bill.invoices.reload.last.invoice_users.where(user_id: another_user.id).first
        @invoice_user_payments = create_list(
          :invoice_user_payment,
          @total_payments,
          invoice_user: another_invoice_user,
          amount: another_invoice_user.amount / @total_payments
        )
      end

      it 'should be able to delete a payment' do
        payment_to_delete = @invoice_user_payments.first
        delete :destroy, params: { id: payment_to_delete.id }
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when payments does not exists' do
      it 'should be able to delete a payment' do
        delete :destroy, params: { id: 'wrong_id' }
        expect(response).to have_http_status :not_found
      end
    end
  end
end
