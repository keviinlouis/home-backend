class InvoiceUserPaymentController < ApplicationController
  before_action :load_invoice, only: [:index, :create]
  before_action :load_payment, only: [:destroy]

  def index
    payments = @invoice_user.invoice_user_payment

    render json: payments
  end

  def create
    @invoice_user.pay(payment_params)
    render json: @invoice_user
  end

  def destroy
    @payment.destroy
  end

  private

  def load_invoice
    @invoice = Invoice.find(params[:invoice_id])
    render json: {}, status: :not_found if @invoice.blank?

    @invoice_user = @invoice.invoice_users.where(user_id: @user.id).first
    render json: {}, status: :not_found if @invoice_user.blank?
  end

  def load_payment
    @payment = InvoiceUserPayment.find params[:id]
    render json: {}, status: :not_found if @payment.blank?
  end

  def check_permission
    is_owner = @payment.invoice_user.user_id == current_user.id

    render json: {}, status: 403 unless is_owner
  end

  def payment_params
    params.only(:amount, :document_path)
  end
end
