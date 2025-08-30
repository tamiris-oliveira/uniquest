class SimulationNotificationJob < ApplicationJob
  queue_as :default

  def perform(simulation_id)
    simulation = Simulation.find(simulation_id)
    
    # Buscar todos os usuários dos grupos associados ao simulado
    user_ids = simulation.groups
                        .joins(:users)
                        .pluck('users.id')
                        .uniq
    
    users = User.where(id: user_ids)
    
    # Enviar email para cada usuário
    users.find_each do |user|
      begin
        SimulationMailer.new_simulation_assigned(user, simulation).deliver_now
        
        # Criar notificação no sistema também
        Notification.create!(
          user: user,
          message: "Novo simulado disponível: #{simulation.title}",
          viewed: false,
          send_date: Time.current
        )
        
        Rails.logger.info "Email enviado para #{user.email} sobre simulado #{simulation.title}"
      rescue => e
        Rails.logger.error "Erro ao enviar email para #{user.email}: #{e.message}"
      end
    end
  end
end
