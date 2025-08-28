class CorrectionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_answer, only: [:index, :create]
  before_action :set_correction, only: [:show, :update, :destroy]

  def index
    @corrections = @answer.corrections
    render json: @corrections
  end

  def create
    @correction = @answer.corrections.build(correction_params.merge(user_id: @current_user.id))

    if @correction.save
      update_attempt_final_grade(@answer.attempt)
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
      update_attempt_final_grade(@correction.answer.attempt)
      render json: @correction
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  def destroy
    attempt = @correction.answer.attempt
    @correction.destroy
    update_attempt_final_grade(attempt)
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


  def update_attempt_final_grade(attempt)
    answers = attempt.answers.includes(:corrections)

    last_corrections = answers.map do |answer|
      answer.corrections.order(correction_date: :desc).first
    end.compact
    total_grade = last_corrections.sum { |correction| correction.grade.to_f }
    attempt.update(final_grade: total_grade)
  end
end
