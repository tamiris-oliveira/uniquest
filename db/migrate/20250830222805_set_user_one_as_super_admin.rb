class SetUserOneAsSuperAdmin < ActiveRecord::Migration[8.0]
  def up
    # Verificar se usuário 1 existe
    user = User.find_by(id: 1)
    
    if user
      # Tornar usuário 1 Super Admin
      user.update!(
        role: 3,                    # Super Admin
        approval_status: 1,         # Approved
        approved_by: 1,             # Auto-aprovado
        approved_at: Time.current
      )
      
      puts "✅ Usuário 1 (#{user.name}) foi definido como Super Admin"
    else
      puts "⚠️  Usuário com ID 1 não encontrado"
    end
  end
  
  def down
    # Reverter usuário 1 para admin normal se necessário
    user = User.find_by(id: 1)
    
    if user && user.role == 3
      user.update!(
        role: 2,                    # Admin normal
        approval_status: 1,         # Approved
        approved_by: nil,
        approved_at: nil
      )
      
      puts "↩️  Usuário 1 foi revertido para Admin normal"
    end
  end
end
