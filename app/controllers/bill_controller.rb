class BillController < ApplicationController
  def index
    bills = @user.bills.paginate(page: params[:page] || 1, per_page: params[:limit] || 20)
    render json: bills
  end

  def show
    bill = @user.bills.find(params[:id])

    render json: bill
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  end

  def create
    bill = @user.owner_bills.create(store_params)

    return render json: bill.errors, status: :unprocessable_entity if bill.errors.any?

    bill.add_event :created, @user

    render json: bill, status: :created
  end

  def update
    bill = @user.owner_bills.find(params[:id])

    bill.update update_params

    bill.add_event :update_details, @user

    render json: bill
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  end

  def destroy
    bill = @user.bills.find(params[:id])

    bill.destroy

    bill.add_event :deleted, @user

    render json: bill
  rescue ActiveRecord::RecordNotFound
    render json: {}, status: :not_found
  end

  def accept
    bill_user = BillUser.where(user_id: @user.id, bill_id: params[:bill_id]).first

    return render json: {}, status: :not_found unless bill_user.present?

    return render json: {} if bill_user.active?

    bill_user.update status: :active

    bill = bill_user.bill

    Notification.notify_user_accept_bill(bill, bill_user.user)

    bill.add_event :user_accepted, @user

    bill.active_all_users unless bill.pending_users?

    render json: bill_user.bill
  end

  def refuse
    bill_user = BillUser.where(user_id: @user.id, bill_id: params[:bill_id]).first

    return render json: {}, status: :not_found unless bill_user.present?

    bill = bill_user.bill

    Notification.notify_user_refused_bill(bill, bill_user.user)

    bill.add_event :user_refused, @user

    bill.remove_next_state_users

    render json: bill
  end

  private

  def store_params
    params.permit(
      :amount,
      :name,
      :description,
      :expires_at,
      :frequency,
      :frequency_type,
      :bill_category_id,
    )
  end

  def update_params
    params.permit(
      :amount,
      :name,
      :description,
      :expires_at,
      :frequency,
      :frequency_type,
      :bill_category_id,
    )
  end

  def list_status
    status = :active

    if params.key?(:status) && BillUser.statuses.include?(params[:status])
      status = params[:status]
    end

    status
  end
end
