class CorrectionNotificationJob < ApplicationJob
  queue_as :default

  def perform(correction_id)
    return unless correction_id.present?
    
    correction = Correction.includes(
      answer: {
        attempt: [:user, :simulation],
        question: []
      }
    ).find_by(id: correction_id)
    
    return unless correction&.answer&.attempt&.user
    
    user = correction.answer.attempt.user
    
    begin
      # Sempre criar notificação no sistema
      simulation_title = correction.answer.attempt.simulation.title
      grade_text = correction.grade.present? ? " (Nota: #{correction.grade.to_f.round(1)})" : ""
      
      Notification.create!(
        user: user,
        message: "Correção disponível para #{simulation_title}#{grade_text}",
        viewed: false,
        send_date: Time.current
      )
      
      # Tentar enviar email (pode falhar se SMTP não configurado)
      if Rails.env.production? && ENV['SMTP_USERNAME'].present?
        CorrectionMailer.correction_completed(user, correction).deliver_now
        Rails.logger.info "Email de correção enviado para #{user.email}"
      else
        Rails.logger.info "Notificação de correção criada para #{user.email} (email não configurado)"
      end
      
    rescue => e
      Rails.logger.error "Erro ao processar correção para #{user.email}: #{e.message}"
    end
  rescue => e
    Rails.logger.error "Erro no job de notificação de correção: #{e.message}"
  end
end
