class CorrectionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_answer, only: [ :index, :create ]
  before_action :set_correction, only: [ :show, :update, :destroy ]

  def index
    @corrections = @answer.corrections
    render json: @corrections
  end

  def create
    @correction = @answer.corrections.build(correction_params.merge(user_id: @current_user.id))

    if @correction.save
      render json: @correction, status: :created, location: correction_url(@correction)
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @correction
  end

  def update
    if @correction.update(correction_params)
      render json: @correction
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @correction.destroy
    head :no_content
  end

  private

  def set_answer
    @answer = Answer.find(params[:answer_id])
  end

  def set_correction
    @correction = Correction.find(params[:id])
  end

  def correction_params
    params.require(:correction).permit(:grade, :feedback, :correction_date)
  end
end
