class AlternativesController < ApplicationController
  before_action :authenticate_request!
  before_action :set_question
  before_action :set_alternative, only: %i[show update destroy]

  def index
    alternatives = @question.alternatives
    render json: alternatives
  end

  def create
    alternative = @question.alternatives.build(alternative_params)
    if alternative.save
      render json: alternative, status: :created, location: question_alternative_url(@question, alternative)
    else
      render json: { errors: alternative.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @alternative
  end

  def update
    if @alternative.update(alternative_params)
      render json: @alternative
    else
      render json: { errors: @alternative.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @alternative.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: "Falha ao excluir a alternativa." }, status: :unprocessable_entity
  end

  private

  def set_question
    @question = Question.find_by(id: params[:question_id])
    render json: { error: "Questão não encontrada." }, status: :not_found unless @question
  end

  def set_alternative
    @alternative = @question.alternatives.find_by(id: params[:id])
    render json: { error: "Alternativa não encontrada." }, status: :not_found unless @alternative
  end

  def alternative_params
    params.require(:alternative).permit(:text, :correct)
  end
end
