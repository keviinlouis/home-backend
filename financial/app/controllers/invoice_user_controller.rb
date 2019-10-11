class InvoiceUserController < ApplicationController
  before_action :load_invoice

  def pay
    # TODO Upload image
    @invoice_user.pay
    render json: @invoice_user
  end

  private

  def load_invoice
    @invoice = Invoice.find(params[:id])
    @invoice_user = @invoice.invoice_users.where(user_id: @user.id).first
    render json: {}, status: :not_found if @invoice_user.blank?
  end
end
