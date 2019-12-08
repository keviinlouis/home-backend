class BillEventController < ApplicationController
  before_action :load_bill, except: [:destroy]

  def index
    page = params[:page] || 1
    limit = params[:limit] || 20
    events = @bill.bill_events
               .order(created_at: :desc)
               .paginate(page: page, per_page: limit)
    render json: events
  end

  def create
    bill_event = @bill.bill_events.create(user: current_user, kind: :message, message: params[:message])
    render json: bill_event, status: :created
  end

  def destroy
    bill_event = BillEvent.where(user_id: current_user.id, id: params[:id]).first

    return render_not_found if bill_event.blank?

    bill_event.destroy

    render json: bill_event
  end
end
