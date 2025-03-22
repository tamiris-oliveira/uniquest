class AnswersController < ApplicationController
  before_action :authenticate_request!
  before_action :set_attempt, only: [ :index, :create ]
  before_action :set_answer, only: [ :show, :update, :destroy ]

  def index
    @answers = @attempt.answers
    render json: @answers
  end

  def create
    @answer = @attempt.answers.build(answer_params)

    if @answer.save
      render json: @answer, status: :created, location: answer_url(@answer)
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @answer
  end

  def update
    if @answer.update(answer_params)
      render json: @answer
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @answer.destroy
    head :no_content
  end

  private

  def set_attempt
    @attempt = Attempt.find(params[:attempt_id])
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:student_answer, :correct, :question_id, :attempt_id)
  end
end
