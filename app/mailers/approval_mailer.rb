class ApprovalMailer < ApplicationMailer
  default from: 'noreply@uniquest.com'

  def user_approved(user)
    @user = user
    @approver = user.approved_by_user
    @frontend_url = 'https://uniquest-two.vercel.app'
    @login_url = "#{@frontend_url}/login"
    
    # Definir tipo de conta baseado no role
    @account_type = case user.role
    when 1 then 'Professor'
    when 2 then 'Administrador'
    when 3 then 'Super Administrador'
    else 'Usuário'
    end
    
    mail(
      to: user.email,
      subject: "Conta Aprovada - Bem-vindo ao Uniquest!"
    )
  end

  def user_rejected(user, reason = nil)
    @user = user
    @reason = reason
    @approver = user.approved_by_user
    @frontend_url = 'https://uniquest-two.vercel.app'
    @contact_url = "#{@frontend_url}/contato"
    
    # Definir tipo de conta baseado no role
    @account_type = case user.role
    when 1 then 'Professor'
    when 2 then 'Administrador'
    when 3 then 'Super Administrador'
    else 'Usuário'
    end
    
    mail(
      to: user.email,
      subject: "Solicitação de Conta - Status Atualizado"
    )
  end
end
