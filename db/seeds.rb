# db/seeds.rb

puts "Criando super admin..."
User.find_or_create_by!(email: "superadmin@example.com") do |user|
  user.name = "Super Admin"
  user.password = "senha123"
  user.password_confirmation = "senha123"
  user.role = 2
  user.avatar = ""
end

puts "Criando usuários comuns..."
30.times do |i|
  User.find_or_create_by!(email: "usuario#{i + 1}@exemplo.com") do |user|
    user.name = "Usuário #{i + 1}"
    user.password = "senha123"
    user.password_confirmation = "senha123"
    user.avatar = ""
    user.role = i.even? ? 0 : 1
  end
end

puts "Criando matérias..."
subjects = [
  "Matemática",
  "Português",
  "História",
  "Química",
  "Física",
  "Biologia"
].map do |subject_name|
  Subject.find_or_create_by!(name: subject_name)
end

puts "Criando usuário professor para associar às questões..."
professor = User.find_or_create_by!(email: "professor@example.com") do |u|
  u.name = "Professor Exemplo"
  u.password = "123456"
  u.password_confirmation = "123456"
  u.role = 1
  u.avatar = ""
end

puts "Criando questões..."

questions_data = [
    {
    statement: "Qual é a raiz quadrada de 144?",
    question_type: "Objetiva",
    justification: "Raiz quadrada de 144 é 12 porque 12x12 = 144.",
    user: professor,
    subject: subjects.find { |s| s.name == "Matemática" },
    alternatives_attributes: [
      { text: "10", correct: false },
      { text: "12", correct: true },
      { text: "14", correct: false },
      { text: "16", correct: false }
    ]
  },
  {
    statement: "Qual é a função da fotossíntese nas plantas?",
    question_type: "Discursiva",
    justification: "A fotossíntese é o processo pelo qual as plantas produzem seu alimento a partir da luz solar.",
    user: professor,
    subject: subjects.find { |s| s.name == "Biologia" }
  },
  {
    statement: "Complete a frase: O Brasil é conhecido como o país do ________.",
    question_type: "Discursiva",
    justification: "",
    user: professor,
    subject: subjects.find { |s| s.name == "História" }
  },
  {
    statement: "Qual é o símbolo químico do ouro?",
    question_type: "Objetiva",
    justification: "O símbolo do ouro é Au.",
    user: professor,
    subject: subjects.find { |s| s.name == "Química" },
    alternatives_attributes: [
      { text: "Ag", correct: false },
      { text: "Au", correct: true },
      { text: "Pb", correct: false },
      { text: "Fe", correct: false }
    ]
  },
  {
    statement: "Explique a Lei da Inércia.",
    question_type: "Discursiva",
    justification: "A Lei da Inércia diz que um corpo em repouso ou em movimento retilíneo uniforme tende a permanecer assim a menos que uma força externa atue sobre ele.",
    user: professor,
    subject: subjects.find { |s| s.name == "Física" }
  },
  {
    statement: "Qual é o valor de π (pi) aproximado?",
    question_type: "Objetiva",
    justification: "π é aproximadamente 3,14.",
    user: professor,
    subject: subjects.find { |s| s.name == "Matemática" },
    alternatives_attributes: [
      { text: "3,14", correct: true },
      { text: "2,71", correct: false },
      { text: "1,61", correct: false },
      { text: "4,13", correct: false }
    ]
  },
  {
    statement: "Descreva o processo de digestão humana.",
    question_type: "Discursiva",
    justification: "A digestão humana é o processo de decomposição dos alimentos para absorção dos nutrientes.",
    user: professor,
    subject: subjects.find { |s| s.name == "Biologia" }
  },
  {
    statement: "Quem foi o primeiro presidente do Brasil?",
    question_type: "Objetiva",
    justification: "Deodoro da Fonseca foi o primeiro presidente do Brasil.",
    user: professor,
    subject: subjects.find { |s| s.name == "História" },
    alternatives_attributes: [
      { text: "Getúlio Vargas", correct: false },
      { text: "Juscelino Kubitschek", correct: false },
      { text: "Deodoro da Fonseca", correct: true },
      { text: "Dom Pedro II", correct: false }
    ]
  },
  {
    statement: "Explique o princípio da conservação da energia.",
    question_type: "Discursiva",
    justification: "A energia total em um sistema isolado permanece constante.",
    user: professor,
    subject: subjects.find { |s| s.name == "Física" }
  },
  {
    statement: "Qual elemento químico tem símbolo 'O'?",
    question_type: "Objetiva",
    justification: "O símbolo 'O' representa o Oxigênio.",
    user: professor,
    subject: subjects.find { |s| s.name == "Química" },
    alternatives_attributes: [
      { text: "Ouro", correct: false },
      { text: "Oxigênio", correct: true },
      { text: "Osmium", correct: false },
      { text: "Oxalato", correct: false }
    ]
  },
  {
    statement: "Qual é o sujeito da frase: 'O cachorro corre no parque'?",
    question_type: "Objetiva",
    justification: "O sujeito é o termo que indica quem pratica a ação; nesse caso, 'O cachorro'.",
    user: professor,
    subject: subjects.find { |s| s.name == "Português" },
    alternatives_attributes: [
      { text: "corre", correct: false },
      { text: "no parque", correct: false },
      { text: "O cachorro", correct: true },
      { text: "a ação de correr", correct: false }
    ]
  },
  {
    statement: "Defina a Revolução Industrial.",
    question_type: "Discursiva",
    justification: "A Revolução Industrial foi a transição para novos processos de manufatura no século XVIII e XIX.",
    user: professor,
    subject: subjects.find { |s| s.name == "História" }
  }
]

questions_data.each do |q_data|
  Question.find_or_create_by!(statement: q_data[:statement], user: q_data[:user]) do |q|
    q.assign_attributes(q_data.except(:statement, :user))
  end
end
