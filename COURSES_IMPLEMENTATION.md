# Implementação de Divisão de Usuários por Curso

## Resumo

Esta implementação adiciona a funcionalidade de dividir usuários por curso no sistema Uniquest, permitindo melhor organização e filtragem dos dados.

## Estrutura Implementada

### 1. Banco de Dados

#### Nova Tabela: `courses`
```sql
CREATE TABLE courses (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  code VARCHAR(20) NOT NULL UNIQUE,
  description TEXT,
  created_at DATETIME NOT NULL,
  updated_at DATETIME NOT NULL,
  INDEX(name),
  UNIQUE INDEX(code)
);
```

#### Modificação na Tabela: `users`
```sql
ALTER TABLE users ADD COLUMN course_id BIGINT;
ALTER TABLE users ADD INDEX(course_id);
ALTER TABLE users ADD FOREIGN KEY (course_id) REFERENCES courses(id);
```

### 2. Models

#### Course Model
- **Associações**: `has_many :users`, `has_many :groups`, `has_many :simulations`
- **Validações**: name (obrigatório, 2-100 chars), code (obrigatório, único, 2-20 chars)
- **Scopes**: `active`, `by_name`
- **Métodos**: `users_count`, `groups_count`

#### User Model (Atualizado)
- **Nova Associação**: `belongs_to :course, optional: true`
- **Novos Scopes**: `by_course(course)`
- **Novos Métodos**: `course_name`, `course_code`

### 3. Controllers

#### CoursesController
- `GET /courses` - Lista todos os cursos com contagem de usuários
- `GET /courses/:id` - Mostra curso específico com usuários
- `GET /courses/:id/users` - Lista usuários do curso com filtros
- `GET /courses/:id/statistics` - Estatísticas do curso

#### UsersController (Atualizado)
- `GET /users` - Lista usuários com filtros por curso, role, etc.
- `GET /users/by_course` - Agrupa usuários por curso
- `GET /users/statistics` - Estatísticas gerais dos usuários

## Como Usar

### 1. Executar Migrações
```bash
bundle exec rails db:migrate
```

### 2. Popular com Dados de Exemplo
```bash
bundle exec rails db:seed
```

### 3. Exemplos de Uso da API

#### Listar todos os cursos
```bash
GET /courses
# ou
GET /api/v1/courses
```

#### Filtrar usuários por curso
```bash
GET /users?course_id=1
GET /api/v1/users?course_id=1
```

#### Usuários agrupados por curso
```bash
GET /users/by_course
GET /api/v1/users/by_course
```

#### Estatísticas de um curso
```bash
GET /courses/1/statistics
GET /api/v1/courses/1/statistics
```

#### Filtros combinados
```bash
# Estudantes de um curso específico
GET /users?course_id=1&role=student

# Usuários sem curso
GET /users?course_id=

# Busca por nome
GET /users?search=João
```

### 4. Exemplos de Resposta JSON

#### Listar Cursos
```json
[
  {
    "id": 1,
    "name": "Ciência da Computação",
    "code": "CC",
    "description": "Curso de Ciência da Computação...",
    "users_count": 5,
    "created_at": "2025-08-27T14:21:08.000Z"
  }
]
```

#### Usuários por Curso
```json
{
  "courses": [
    {
      "id": 1,
      "name": "Ciência da Computação",
      "code": "CC",
      "users_count": 5,
      "users": [
        {
          "id": 1,
          "name": "Alice Johnson",
          "email": "alice.johnson@estudante.edu",
          "role": "student",
          "course": {
            "id": 1,
            "name": "Ciência da Computação",
            "code": "CC"
          },
          "groups_count": 2,
          "simulations_count": 3,
          "created_at": "2025-08-27T14:21:08.000Z"
        }
      ]
    }
  ],
  "users_without_course": [
    {
      "id": 10,
      "name": "Admin Sistema",
      "email": "admin@sistema.com",
      "role": "admin",
      "course": null,
      "groups_count": 0,
      "simulations_count": 0,
      "created_at": "2025-08-27T14:21:08.000Z"
    }
  ]
}
```

#### Estatísticas
```json
{
  "total_users": 20,
  "users_by_course": {
    "Ciência da Computação": 5,
    "Engenharia de Software": 4,
    "Sistemas de Informação": 4,
    "Análise e Desenvolvimento de Sistemas": 4
  },
  "users_by_role": {
    "student": 17,
    "teacher": 4,
    "admin": 1
  },
  "users_without_course": 2,
  "courses_with_most_users": {
    "Ciência da Computação": 5,
    "Engenharia de Software": 4
  }
}
```

## Benefícios da Implementação

### 1. Organização Melhorada
- Usuários agrupados por curso
- Fácil identificação de pertencimento
- Hierarquia clara: Curso → Usuários → Grupos → Simulações

### 2. Filtragem Avançada
- Filtrar usuários por curso específico
- Combinar filtros (curso + role + grupo)
- Busca textual com filtros

### 3. Estatísticas Detalhadas
- Contagem de usuários por curso
- Distribuição por roles dentro de cada curso
- Cursos mais populares
- Usuários sem curso atribuído

### 4. Escalabilidade
- Índices otimizados para consultas rápidas
- Queries eficientes com joins
- Paginação implementada

### 5. Flexibilidade
- Curso opcional (permite usuários sem curso)
- API REST completa
- Suporte a JSON e HTML

## Próximos Passos Sugeridos

1. **Interface Web**: Criar views HTML para gerenciar cursos
2. **Autenticação**: Implementar controle de acesso baseado em curso
3. **Relatórios**: Dashboards com gráficos por curso
4. **Importação**: Sistema para importar usuários em lote por curso
5. **Notificações**: Notificações específicas por curso

## Estrutura de Arquivos Modificados/Criados

```
uniquest-backend/
├── db/
│   ├── migrate/
│   │   ├── 20250827142108_create_courses.rb
│   │   └── 20250827142226_add_course_to_users.rb
│   └── seeds.rb (atualizado)
├── app/
│   ├── models/
│   │   ├── course.rb (novo)
│   │   └── user.rb (atualizado)
│   └── controllers/
│       ├── courses_controller.rb (novo)
│       └── users_controller.rb (atualizado)
├── config/
│   └── routes.rb (atualizado)
└── COURSES_IMPLEMENTATION.md (este arquivo)
```

## Comandos Úteis

```bash
# Ver status das migrações
bundle exec rails db:migrate:status

# Resetar banco (cuidado!)
bundle exec rails db:drop db:create db:migrate db:seed

# Console Rails para testar
bundle exec rails console

# Exemplos no console:
# Course.all
# User.by_course(1)
# Course.find(1).users.students
```
