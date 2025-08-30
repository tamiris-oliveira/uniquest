class SimulationNotificationJob < ApplicationJob
  queue_as :default

  def perform(simulation_id)
    return unless simulation_id.present?
    
    simulation = Simulation.find_by(id: simulation_id)
    return unless simulation
    
    # Buscar todos os usuários dos grupos associados ao simulado
    user_ids = simulation.groups
                        .joins(:users)
                        .pluck('users.id')
                        .uniq
    
    return if user_ids.empty?
    
    users = User.where(id: user_ids)
    
    # Enviar email para cada usuário
    users.find_each do |user|
      begin
        # Sempre criar notificação no sistema
        Notification.create!(
          user: user,
          message: "Novo simulado disponível: #{simulation.title}",
          viewed: false,
          send_date: Time.current
        )
        
        # Tentar enviar email (pode falhar se SMTP não configurado)
        if Rails.env.production? && ENV['SMTP_USERNAME'].present?
          SimulationMailer.new_simulation_assigned(user, simulation).deliver_now
          Rails.logger.info "Email enviado para #{user.email} sobre simulado #{simulation.title}"
        else
          Rails.logger.info "Notificação criada para #{user.email} sobre simulado #{simulation.title} (email não configurado)"
        end
        
      rescue => e
        Rails.logger.error "Erro ao processar notificação para #{user.email}: #{e.message}"
        # Continua processando outros usuários mesmo se um falhar
      end
    end
  rescue => e
    Rails.logger.error "Erro no job de notificação de simulado: #{e.message}"
  end
end
