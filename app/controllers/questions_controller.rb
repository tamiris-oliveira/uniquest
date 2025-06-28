class QuestionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_question, only: [ :show, :update, :destroy ]

  def index
    @questions = Question.includes(:alternatives).all
    render json: @questions.to_json(include: :alternatives)
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      render json: @question.to_json(include: :alternatives), status: :created, location: question_url(@question)
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @question.to_json(include: :alternatives)
  end

  def update
    if @question.update(question_params)
      render json: @question.to_json(include: :alternatives)
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    render json: { message: "Questão excluída com sucesso" }, status: :ok
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:statement, :question_type, :justification, :user_id, :subject_id, alternatives_attributes: [ :id, :text, :correct, :_destroy ])
  end
end
