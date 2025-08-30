class CorrectionMailer < ApplicationMailer
  default from: 'noreply@uniquest.com'

  def correction_completed(user, correction)
    @user = user
    @correction = correction
    @answer = correction.answer
    @question = @answer.question
    @attempt = @answer.attempt
    @simulation = @attempt.simulation
    @frontend_url = 'https://uniquest-c8sk8xn99-tamiris73s-projects.vercel.app'
    @correction_url = "#{@frontend_url}/attempts/#{@attempt.id}/corrections"
    
    mail(
      to: user.email,
      subject: "Correção Disponível - #{@simulation.title}"
    )
  end
end
