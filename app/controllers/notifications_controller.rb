class NotificationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_notification, only: [ :show, :update, :destroy ]

  def index
    @notifications = @current_user.notifications
    render json: notifications_json(@notifications)
  end

  def show
    render json: notification_json(@notification)
  end

  def create
    @notification = @current_user.notifications.build(notification_params)

    if @notification.save
      render json: notification_json(@notification), status: :created, location: notification_url(@notification)
    else
      render json: @notification.errors, status: :unprocessable_entity
    end
  end

  def update
    if @notification.update(notification_params)
      render json: notification_json(@notification)
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
    @notification = @current_user.notifications.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Notificação não encontrada" }, status: :not_found
  end

  def notification_params
    params.require(:notification).permit(:message, :viewed, :send_date)
  end

  def notification_json(notification)
    {
      id: notification.id.to_s,
      message: notification.message,
      viewed: notification.viewed,
      send_date: notification.send_date,
      user_id: notification.user_id.to_s,
      created_at: notification.created_at,
      updated_at: notification.updated_at
    }
  end

  def notifications_json(notifications)
    notifications.map { |notification| notification_json(notification) }
  end
end
