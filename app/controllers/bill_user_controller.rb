class BillUserController < ApplicationController
  def create
    bill = current_user.bills.find_by_id(params[:bill_id])

    return render_not_found if bill.blank?

    bill.update_users params[:users]

    return json_with_errors bill.errors if bill.errors.any?

    bill.new_users.where.not(user_id: current_user.id).each { |bill_user| Notification.notify_bill_added(bill_user.user, bill) }

    bill.old_users.where.not(user_id: current_user.id).each { |bill_user| Notification.notify_bill_edited(bill_user.user, bill) }

    bill.add_event :update_users, current_user

    render json: bill.reload, status: :created
  end
end
