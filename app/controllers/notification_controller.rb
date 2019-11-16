class NotificationController < ApplicationController
  before_action :load_notification, only: [:read]

  def index
    page = params[:page] || 1
    render json: current_user.notification.page(page)
  end

  def update
    @notification.read!
    render json: @notification
  end

  private

  def load_notification
    @notification = Notification.find params[:id]
  end
end
