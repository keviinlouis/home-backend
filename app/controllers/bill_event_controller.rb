class BillEventController < ApplicationController
  before_action :load_bill

  def index
    page = params[:page] || 1
    limit = params[:limit] || 20
    events = @bill.bill_events
      .order(created_at: :desc)
      .paginate(page: page, per_page: limit)
    render json: events
  end

  def create
    bill_event = @bill.bill_events.create(user: @user, kind: :message, message: params[:message])
    render json: bill_event, status: :created
  end

  def destroy
    bill_event = @bill.bill_events.where(user_id: @user.id, id: params[:id]).first

    return render json: {}, status: :not_found unless bill_event.present?

    bill_event.destroy

    render json: bill_event
  end

  private

  def create_params
    params.permit(
       :message
    )
  end
end
