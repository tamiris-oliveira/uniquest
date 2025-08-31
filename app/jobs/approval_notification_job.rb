class ApprovalNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, action, reason = nil)
    return unless user_id.present? && action.present?
    
    user = User.find_by(id: user_id)
    return unless user
    
    begin
      case action.to_s
      when 'approved'
        # Sempre criar notificação
        Notification.create!(
          user: user,
          message: "Sua conta foi aprovada! Você já pode acessar a plataforma.",
          viewed: false,
          send_date: Time.current
        )
        
        # Enviar email apenas em produção se SMTP configurado
        if Rails.env.production? && ENV['SMTP_USERNAME'].present?
          ApprovalMailer.user_approved(user).deliver_now
          Rails.logger.info "Email de aprovação enviado para #{user.email}"
        else
          Rails.logger.info "Notificação de aprovação criada para #{user.email} (email não configurado)"
        end
        
      when 'rejected'
        # Sempre criar notificação
        message = reason.present? ? "Sua solicitação foi rejeitada. Motivo: #{reason}" : "Sua solicitação foi rejeitada."
        Notification.create!(
          user: user,
          message: message,
          viewed: false,
          send_date: Time.current
        )
        
        # Enviar email apenas em produção se SMTP configurado
        if Rails.env.production? && ENV['SMTP_USERNAME'].present?
          ApprovalMailer.user_rejected(user, reason).deliver_now
          Rails.logger.info "Email de rejeição enviado para #{user.email}"
        else
          Rails.logger.info "Notificação de rejeição criada para #{user.email} (email não configurado)"
        end
      end
      
    rescue => e
      Rails.logger.error "Erro ao processar notificação de aprovação para #{user.email}: #{e.message}"
    end
    
  rescue => e
    Rails.logger.error "Erro no job de notificação de aprovação: #{e.message}"
  end
end
