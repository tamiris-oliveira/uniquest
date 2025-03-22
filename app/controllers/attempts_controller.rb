class AttemptsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_attempt, only: [ :show, :update, :destroy ]

  def index
    @attempts = Attempt.all
    render json: @attempts
  end

  def show
    render json: @attempt
  end

  def create
    @attempt = Attempt.new(attempt_params)
    if @attempt.save
      render json: @attempt, status: :created
    else
      render json: @attempt.errors, status: :unprocessable_entity
    end
  end

  def update
    if @attempt.update(attempt_params)
      render json: @attempt
    else
      render json: @attempt.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @attempt.destroy
  end

  private

  def set_attempt
    @attempt = Attempt.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Attempt not found" }, status: :not_found
  end

  def attempt_params
    params.require(:attempt).permit(:attempt_date, :simulation_id, :user_id)
  end
end
