# Preview all emails at http://localhost:3000/rails/mailers/simulation_mailer
class SimulationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/simulation_mailer/new_simulation_assigned
  def new_simulation_assigned
    # Criar dados de exemplo para preview
    user = User.first || User.new(
      name: "João Silva",
      email: "joao@exemplo.com"
    )
    
    simulation = Simulation.first || Simulation.new(
      title: "Simulado de Matemática - Álgebra Linear",
      description: "Simulado focado em conceitos básicos de álgebra linear, incluindo matrizes, determinantes e sistemas lineares.",
      deadline: 1.week.from_now.in_time_zone("America/Sao_Paulo"),
      time_limit: 120,
      max_attempts: 3
    )
    
    # Simular grupos associados
    unless simulation.persisted?
      simulation.groups = [
        Group.new(name: "Turma A - Engenharia", invite_code: "ENG2024A"),
        Group.new(name: "Turma B - Matemática", invite_code: "MAT2024B")
      ]
    end
    
    SimulationMailer.new_simulation_assigned(user, simulation)
  end
end
