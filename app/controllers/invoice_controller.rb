class InvoiceController < ApplicationController
  def index
    page = params[:page] || 1
    limit = params[:limit] || 20
    status = params[:status].to_s.parameterize.underscore.to_sym
    bill = params[:bill]

    query = Invoice.joins(:invoice_users)
              .where(invoice_users: { user_id: @user.id })

    if status && InvoiceUser.statuses.include?(status)
      query = query.where(status: status)
    end

    if bill
      query = query.where(bill_id: bill)
    end

    render json: query.paginate(page: page, per_page: limit)
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
