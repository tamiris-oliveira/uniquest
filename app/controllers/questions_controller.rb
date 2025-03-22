class QuestionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_simulation
  before_action :set_question, only: [ :show, :update, :destroy ]

  def index
    @questions = @simulation.questions
    render json: @questions
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      @simulation.questions << @question

      render json: @question, status: :created, location: simulation_question_url(@simulation, @question)
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @question
  end

  def update
    if @question.update(question_params)
      render json: @question
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    render json: { message: "Question deleted successfully" }, status: :ok
  end

  private

  def set_simulation
    @simulation = Simulation.find(params[:simulation_id])
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:statement, :question_type, :justification, :user_id)
  end
end
