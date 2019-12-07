class NotificationController < ApplicationController
  before_action :load_notification, only: [:update]

  def index
    page = params[:page] || 1
    limit = params[:limit] || 20
    render json: current_user.notification.order(created_at: :desc).limit(limit).page(page)
  end

  def update
    @notification.read!
    render json: @notification
  end

  private

  def load_notification
    @notification = current_user.notification.find_by_id params[:id]

    render_not_found if @notification.blank?
  end
end
