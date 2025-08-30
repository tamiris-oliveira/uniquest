class SimulationMailer < ApplicationMailer
  default from: 'noreply@uniquest.com'

  def new_simulation_assigned(user, simulation)
    @user = user
    @simulation = simulation
    @groups = simulation.groups.joins(:users).where(users: { id: user.id })
    @frontend_url = 'https://uniquest-c8sk8xn99-tamiris73s-projects.vercel.app'
    @simulation_url = "#{@frontend_url}/simulations/#{simulation.id}"
    
    mail(
      to: user.email,
      subject: "Novo Simulado Disponível: #{simulation.title}"
    )
  end
end
