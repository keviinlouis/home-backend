class InvoiceController < ApplicationController
  def index
    page = params[:page] || 1
    limit = params[:limit] || 20

    invoices = Invoice.joins(:invoice_users)
                 .where(status: :available)
                  .where(invoice_users: { user_id: @user.id })
                 .paginate(page: page, per_page: limit)

    render json: invoices
  end

  def update
    invoice = Invoice.find(params[:id])

    return render json: {}, status: 404 if invoice.nil? || invoice.bill.user_id != @user.id

    invoice.update status: :available

    render json: invoice.reload
  end

  private

  def invoice_where_params
    query = { invoice: {} }

    query[:bill_id] = params[:bill_id] if params[:bill_id].present?
    query[:status] = params[:status] if params[:status].present?

    query
  end
end
