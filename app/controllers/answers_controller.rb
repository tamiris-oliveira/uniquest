class AnswersController < ApplicationController
  before_action :authenticate_request!
  before_action :set_attempt, only: [:index, :create]
  before_action :set_answer, only: [:show, :update, :destroy]

  def index
    answers = @attempt.answers.includes(:corrections, question: :alternatives)
    render json: answers.map { |a| answer_with_question_json(a) }
  end

  def create
    @answer = @attempt.answers.build(answer_params)
  
    if @answer.save
      # Verifica se a questão é objetiva para corrigir automaticamente
      if @answer.question.question_type == "Objetiva"
        auto_correct_objective_answer(@answer)
      end
  
      render json: answer_with_question_json(@answer.reload), status: :created, location: answer_url(@answer)
    else
      render json: @answer.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: answer_with_question_json(@answer)
  end

  def update
    if @answer.update(answer_params.except(:correct, :attempt_id))
      render json: answer_with_question_json(@answer)
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
    @attempt = Attempt.find(params[:attempt_id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tentativa não encontrada" }, status: :not_found
  end

  def set_answer
    @answer = Answer.includes(:corrections, question: :alternatives).find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Resposta não encontrada" }, status: :not_found
  end

  def answer_params
    params.require(:answer).permit(:student_answer, :question_id)
  end

  def answer_with_question_json(answer)
    {
      id: answer.id.to_s,
      student_answer: answer.student_answer,
      correct: answer.correct,
      question_id: answer.question_id.to_s,
      attempt_id: answer.attempt_id.to_s,
      created_at: answer.created_at,
      updated_at: answer.updated_at,
      question: {
        id: answer.question.id.to_s,
        statement: answer.question.statement,
        question_type: answer.question.question_type,
        justification: answer.question.justification,
        alternatives: answer.question.alternatives.map do |alt|
          {
            id: alt.id.to_s,
            text: alt.text,
            correct: alt.correct
          }
        end
      },
      correction: answer.corrections.last ? {
        id: answer.corrections.last.id.to_s,
        grade: answer.corrections.last.grade,
        feedback: answer.corrections.last.feedback,
        correction_date: answer.corrections.last.correction_date
      } : nil
    }
  end
end
