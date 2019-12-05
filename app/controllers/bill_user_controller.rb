class BillUserController < ApplicationController
  def create
    bill = @user.bills.find_by_id(params[:bill_id])

    return render json: {}, status: :not_found unless bill.present?

    bill.update_users params[:users]

    bill.new_users.where.not(user_id: current_user.id).each { |bill_user| Notification.notify_bill_added(bill_user.user, bill) }

    bill.old_users.where.not(user_id: current_user.id).each { |bill_user| Notification.notify_bill_edited(bill_user.user, bill) }

    return json_with_errors bill.errors if bill.errors.any?

    bill.add_event :update_users, @user

    render json: bill.reload, status: :created
  end
end
