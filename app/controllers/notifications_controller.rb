class NotificationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_notification, only: [ :show, :update, :destroy ]

  def index
    @notifications = @current_user.notifications
    render json: @notifications
  end

  def show
    render json: @notification
  end

  def create
    @notification = @current_user.notifications.build(notification_params)

    if @notification.save
      render json: @notification, status: :created, location: notification_url(@notification)
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  def update
    if @notification.update(notification_params)
      render json: @notification
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @notification.destroy
    head :no_content
  end

  private

  def set_notification
    @notification = @current_user.notifications.find(params[:id])
  end

  def notification_params
    params.require(:notification).permit(:message, :viewed, :send_date)
  end
end
