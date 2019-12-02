class InvoiceUserPaymentController < ApplicationController
  before_action :load_invoice_user, only: [:index, :create]
  before_action :load_payment, only: [:destroy]

  def index
    payments = @invoice_user.invoice_user_payment

    render json: payments
  end

  def create
    render json: @invoice_user.pay(payment_params)
  end

  def destroy
    @payment.destroy
  end

  private

  def load_invoice_user
    @invoice_user = InvoiceUser.find_by(id: params[:invoice_user_id])

    render json: {}, status: :forbidden unless @invoice_user.invoice.bill_user?(current_user.id)

    render json: {}, status: :not_found if @invoice_user.blank?
  end

  def load_payment
    @payment = InvoiceUserPayment.includes(invoice_user: [:user, :invoice, bill_user: :bill]).find params[:id]
    render json: {}, status: :not_found if @payment.blank?
  end

  def check_permission
    is_owner = @payment.invoice_user.user.id == current_user.id

    render json: {}, status: :forbidden unless is_owner
  end

  def payment_params
    params.permit(:amount, :image)
  end
end
