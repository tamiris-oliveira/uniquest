# db/seeds_super_admin.rb

puts "Criando super admin..."
User.find_or_create_by!(email: "superadmin@example.com") do |user|
  user.name = "Super Admin"
  user.password = "senha123"
  user.password_confirmation = "senha123"
  user.role = 2
  user.avatar = ""
end

puts "Super admin criado com sucesso!"
puts "Email: superadmin@example.com"
puts "Senha: senha123"
