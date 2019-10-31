class BillUserController < ApplicationController
  def create
    bill = @user.bills.find_by_id(params[:bill_id])

    return render json: {}, status: :not_found unless bill.present?

    bill.update_users params[:users]

    return render json: bill.errors, status: :unprocessable_entity if bill.errors.any?

    bill.add_event :update_users, @user

    render json: bill.reload, status: :created
  end
end
