# db/seeds.rb - Apenas Super Admin para produção

puts "🚀 Iniciando seed para produção..."
puts "Criando apenas Super Admin..."

User.find_or_create_by!(email: "superadmin@example.com") do |user|
  user.name = "Super Admin"
  user.password = "senha123"
  user.password_confirmation = "senha123"
  user.role = 2
  user.avatar = ""
end

puts "✅ Super Admin criado com sucesso!"
puts "📧 Email: superadmin@example.com"
puts "🔑 Senha: senha123"
puts "🎯 Role: 2 (Super Admin)"
