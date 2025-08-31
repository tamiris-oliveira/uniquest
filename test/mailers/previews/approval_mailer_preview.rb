class ApprovalMailerPreview < ActionMailer::Preview
  def user_approved
    # Criar usuário de exemplo para preview
    user = User.new(
      id: 123,
      name: "João Silva",
      email: "joao.silva@example.com",
      role: 1, # Professor
      approval_status: :approved,
      approved_at: Time.current,
      approved_by: 456
    )
    
    # Criar curso de exemplo
    course = Course.new(
      id: 1,
      name: "Ciência da Computação",
      code: "CC"
    )
    user.define_singleton_method(:course) { course }
    
    # Criar aprovador de exemplo
    approver = User.new(
      id: 456,
      name: "Admin Sistema",
      email: "admin@uniquest.com"
    )
    user.define_singleton_method(:approved_by_user) { approver }
    
    ApprovalMailer.user_approved(user)
  end

  def user_rejected
    # Criar usuário de exemplo para preview
    user = User.new(
      id: 124,
      name: "Maria Santos",
      email: "maria.santos@example.com",
      role: 1, # Professor
      approval_status: :rejected,
      approved_at: Time.current,
      approved_by: 456
    )
    
    # Criar curso de exemplo
    course = Course.new(
      id: 1,
      name: "Engenharia de Software",
      code: "ES"
    )
    user.define_singleton_method(:course) { course }
    
    # Criar aprovador de exemplo
    approver = User.new(
      id: 456,
      name: "Admin Sistema",
      email: "admin@uniquest.com"
    )
    user.define_singleton_method(:approved_by_user) { approver }
    
    reason = "Documentação incompleta. Por favor, envie todos os documentos necessários."
    
    ApprovalMailer.user_rejected(user, reason)
  end
end
