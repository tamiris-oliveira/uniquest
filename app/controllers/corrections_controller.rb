class CorrectionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_answer, only: [:index, :create]
  before_action :set_correction, only: [:show, :update, :destroy]

  def index
    @corrections = @answer.corrections
    render json: corrections_json(@corrections)
  end

  def create
    @correction = @answer.corrections.build(correction_params.merge(
      user_id: @current_user.id,
      correction_date: Time.current
    ))

    if @correction.save
      update_attempt_final_grade(@answer.attempt)
      
      # Enviar notificação por email para o estudante
      begin
        CorrectionNotificationJob.perform_later(@correction.id)
      rescue => e
        Rails.logger.error "Erro ao enfileirar job de correção: #{e.message}"
        # Não falha a criação da correção se o job falhar
      end
      
      render json: correction_json(@correction), status: :created, location: correction_url(@correction)
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: correction_json(@correction)
  end

  def update
    if @correction.update(correction_params.merge(correction_date: Time.current))
      update_attempt_final_grade(@correction.answer.attempt)
      
      # Enviar notificação por email para o estudante sobre a atualização
      begin
        CorrectionNotificationJob.perform_later(@correction.id)
      rescue => e
        Rails.logger.error "Erro ao enfileirar job de correção: #{e.message}"
        # Não falha a atualização da correção se o job falhar
      end
      
      render json: correction_json(@correction)
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
    @answer = Answer.find(params[:answer_id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Resposta não encontrada" }, status: :not_found
  end

  def set_correction
    @correction = Correction.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Correção não encontrada" }, status: :not_found
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

  def correction_json(correction)
    {
      id: correction.id.to_s,
      grade: correction.grade,
      feedback: correction.feedback,
      correction_date: correction.correction_date,
      answer_id: correction.answer_id.to_s,
      user_id: correction.user_id.to_s,
      created_at: correction.created_at,
      updated_at: correction.updated_at
    }
  end

  def corrections_json(corrections)
    corrections.map { |correction| correction_json(correction) }
  end
end
