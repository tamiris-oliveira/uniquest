class CorrectionMailer < ApplicationMailer
  default from: 'noreply@uniquest.com'

  def correction_completed(user, correction)
    @user = user
    @correction = correction
    @answer = correction.answer
    @question = @answer.question
    @attempt = @answer.attempt
    @simulation = @attempt.simulation
    
    mail(
      to: user.email,
      subject: "Correção Disponível - #{@simulation.title}"
    )
  end
end
