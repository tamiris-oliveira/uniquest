# db/seeds.rb - Apenas Super Admin para produção

puts "👑 Iniciando seed para produção..."

# Verificar se já existe Super Admin
existing_super_admin = User.find_by(email: "superadmin@admin.uniquest.com")

if existing_super_admin
  puts "🔍 Super Admin já existe, verificando status..."
  
  # Garantir que o Super Admin sempre tenha status correto
  if existing_super_admin.approval_status != 'approved' || existing_super_admin.role != 3
    existing_super_admin.update!(
      role: 3,
      approval_status: :approved,
      approved_by: nil,
      approved_at: Time.current
    )
    puts "✅ Super Admin atualizado com status correto!"
  else
    puts "✅ Super Admin já está com status correto!"
  end
  
  super_admin = existing_super_admin
else
  puts "📝 Criando novo Super Admin..."
  
  super_admin = User.create!(
    name: "Super Administrador",
    email: "superadmin@admin.uniquest.com",
    password: "senha123",
    password_confirmation: "senha123",
    role: 3,  # Super Admin
    approval_status: :approved,
    approved_by: nil,  # Auto-aprovado
    approved_at: Time.current,
    avatar: ""
  )
  
  puts "✅ Super Admin criado com sucesso!"
end

puts "📧 Email: #{super_admin.email}"
puts "🔑 Senha: senha123"
puts "👑 Role: #{super_admin.role} (Super Admin)"
puts "✅ Status: #{super_admin.approval_status}"
puts "📅 Aprovado em: #{super_admin.approved_at}"
