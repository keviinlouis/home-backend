class BillController < ApplicationController
  def index
    bills = current_user.bills.paginate(page: params[:page] || 1, per_page: params[:limit] || 20)
    render json: bills
  end

  def show
    bill = current_user.bills.find_by_id(params[:id])

    return render_not_found if bill.blank?

    render json: bill
  end

  def create
    bill = current_user.owner_bills.create(store_params)

    return json_with_errors bill.errors if bill.errors.any?

    bill.add_event :created, current_user

    render json: bill, status: :created
  end

  def update
    bill = current_user.owner_bills.find_by_id(params[:id])

    return render_not_found if bill.blank?

    bill.update update_params

    return json_with_errors bill.errors if bill.errors.any?

    bill.add_event :update_details, current_user

    bill.bill_users.where.not(user_id: current_user.id).each do |bill_user|
      Notification.notify_bill_edited bill_user.user, bill
    end

    render json: bill
  end

  def destroy
    bill = current_user.bills.find_by_id(params[:id])

    return render_not_found if bill.blank?

    bill.destroy

    bill.add_event :deleted, current_user

    render json: bill
  end

  def accept
    bill_user = BillUser.where(user_id: current_user.id, bill_id: params[:bill_id]).first

    return render_not_found unless bill_user.present?

    return render json: {} if bill_user.active?

    bill_user.update status: :active

    bill = bill_user.bill

    Notification.notify_user_accept_bill(bill, bill_user.user)

    bill.add_event :user_accepted, current_user

    bill.active_all_users unless bill.pending_users?

    render json: bill_user.bill
  end

  def refuse
    bill_user = BillUser.where(user_id: current_user.id, bill_id: params[:bill_id]).first

    return render_not_found unless bill_user.present?

    bill = bill_user.bill

    Notification.notify_user_refused_bill(bill, bill_user.user)

    bill.add_event :user_refused, current_user

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
end
