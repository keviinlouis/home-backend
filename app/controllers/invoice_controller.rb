class InvoiceController < ApplicationController
  def index
    page = params[:page] || 1
    limit = params[:limit] || 20
    status = params[:status].to_s.parameterize.underscore.to_sym
    bill = params[:bill]

    query = Invoice.joins(bill: :bill_users)
              .where(bill: {bill_users: { user_id: current_user.id }})

    if status && InvoiceUser.statuses.include?(status)
      query = query.where(status: status)
    end

    if bill
      query = query.where(bill_id: bill)
    end

    render json: query.paginate(page: page, per_page: limit)
  end

  def show
    @invoice = Invoice.find_by_id(params[:id])

    unless @invoice.present? && @invoice.bill.bill_users.find_by(user_id: current_user.id)
      return render json: {}, status: :not_found
    end

    render json: @invoice
  end
end
