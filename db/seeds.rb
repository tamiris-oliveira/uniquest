# db/seeds.rb - Apenas Super Admin para produção

puts "👑 Iniciando seed para produção..."
puts "Criando Super Admin..."

User.find_or_create_by!(email: "superadmin@admin.uniquest.com") do |user|
  user.name = "Super Administrador"
  user.password = "senha123"
  user.password_confirmation = "senha123"
  user.role = 3  # Super Admin
  user.approval_status = :approved
  user.approved_by = nil  # Auto-aprovado
  user.approved_at = Time.current
  user.avatar = ""
end

puts "✅ Super Admin criado com sucesso!"
puts "📧 Email: superadmin@admin.uniquest.com"
puts "🔑 Senha: senha123"
puts "👑 Role: 3 (Super Admin)"
puts "✅ Status: Aprovado"
