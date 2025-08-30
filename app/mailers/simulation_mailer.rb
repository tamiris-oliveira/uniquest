class SimulationMailer < ApplicationMailer
  default from: 'noreply@uniquest.com'

  def new_simulation_assigned(user, simulation)
    @user = user
    @simulation = simulation
    @groups = simulation.groups.joins(:users).where(users: { id: user.id })
    
    mail(
      to: user.email,
      subject: "Novo Simulado Disponível: #{simulation.title}"
    )
  end
end
