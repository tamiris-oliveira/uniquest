class CorrectionNotificationJob < ApplicationJob
  queue_as :default

  def perform(correction_id)
    correction = Correction.includes(
      answer: {
        attempt: [:user, :simulation],
        question: []
      }
    ).find(correction_id)
    
    user = correction.answer.attempt.user
    
    begin
      # Enviar email
      CorrectionMailer.correction_completed(user, correction).deliver_now
      
      # Criar notificação no sistema também
      simulation_title = correction.answer.attempt.simulation.title
      grade_text = correction.grade.present? ? " (Nota: #{correction.grade.to_f.round(1)})" : ""
      
      Notification.create!(
        user: user,
        message: "Correção disponível para #{simulation_title}#{grade_text}",
        viewed: false,
        send_date: Time.current
      )
      
      Rails.logger.info "Email de correção enviado para #{user.email}"
    rescue => e
      Rails.logger.error "Erro ao enviar email de correção para #{user.email}: #{e.message}"
    end
  end
end
