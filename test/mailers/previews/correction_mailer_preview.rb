# Preview all emails at http://localhost:3000/rails/mailers/correction_mailer
class CorrectionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/correction_mailer/correction_completed
  def correction_completed
    # Criar dados de exemplo para preview
    user = User.first || User.new(
      name: "Maria Santos",
      email: "maria@exemplo.com"
    )
    
    simulation = Simulation.first || Simulation.new(
      title: "Simulado de Física - Mecânica Clássica"
    )
    
    question = Question.first || Question.new(
      statement: "Explique o conceito de força centrípeta e sua aplicação no movimento circular uniforme. Dê exemplos práticos onde este conceito é fundamental para o entendimento do fenômeno físico."
    )
    
    attempt = Attempt.first || Attempt.new(
      attempt_date: 2.days.ago,
      user: user,
      simulation: simulation
    )
    
    answer = Answer.first || Answer.new(
      student_answer: "A força centrípeta é a força resultante que atua sobre um corpo em movimento circular, sempre direcionada para o centro da trajetória. Esta força é responsável por manter o corpo na trajetória circular, alterando continuamente a direção da velocidade. Exemplos práticos incluem: movimento de satélites ao redor da Terra, carros fazendo curvas, e o movimento de elétrons ao redor do núcleo atômico.",
      correct: true,
      question: question,
      attempt: attempt
    )
    
    correction = Correction.first || Correction.new(
      grade: 8.5,
      feedback: "Excelente resposta! Você demonstrou compreensão clara do conceito de força centrípeta e forneceu exemplos relevantes. Para uma resposta ainda mais completa, poderia ter mencionado a relação matemática F = mv²/r. Continue assim!",
      correction_date: 1.day.ago,
      answer: answer,
      user_id: 1
    )
    
    CorrectionMailer.correction_completed(user, correction)
  end
end
