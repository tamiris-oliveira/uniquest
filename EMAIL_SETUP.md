# 📧 Sistema de Notificações por Email - Uniquest

Este documento explica como configurar e usar o sistema de notificações por email do Uniquest.

## 🎯 Funcionalidades Implementadas

### 1. **Notificação de Novo Simulado**
- **Quando**: Quando um simulado é criado e associado a grupos
- **Quem recebe**: Todos os usuários dos grupos associados ao simulado
- **Conteúdo**: Detalhes do simulado (título, descrição, prazo, tempo limite, etc.)

### 2. **Notificação de Correção Disponível**
- **Quando**: Quando uma correção é criada ou atualizada
- **Quem recebe**: O estudante que fez a resposta
- **Conteúdo**: Nota, feedback, detalhes da questão e resposta

## 🔧 Configuração para Produção

### Variáveis de Ambiente Necessárias

Configure as seguintes variáveis de ambiente no Render.com:

```bash
# Configurações SMTP (exemplo com Gmail)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=gmail.com
SMTP_USERNAME=seu-email@gmail.com
SMTP_PASSWORD=sua-senha-de-app

# URL do seu app (já configurada no Render)
RENDER_EXTERNAL_URL=https://uniquest-g3rp.onrender.com
```

### Como Configurar Gmail para SMTP

1. **Ativar 2FA** na sua conta Google
2. **Gerar Senha de App**:
   - Vá em Configurações da Conta Google
   - Segurança → Verificação em duas etapas
   - Senhas de app → Gerar nova senha
   - Use essa senha na variável `SMTP_PASSWORD`

### Outros Provedores de Email

#### SendGrid
```bash
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=sua-api-key-do-sendgrid
```

#### Mailgun
```bash
SMTP_ADDRESS=smtp.mailgun.org
SMTP_PORT=587
SMTP_DOMAIN=seu-dominio.mailgun.org
SMTP_USERNAME=postmaster@seu-dominio.mailgun.org
SMTP_PASSWORD=sua-senha-do-mailgun
```

## 🧪 Testando o Sistema

### 1. **Visualizar Templates de Email**

Durante desenvolvimento, acesse:
- http://localhost:3000/rails/mailers/simulation_mailer/new_simulation_assigned
- http://localhost:3000/rails/mailers/correction_mailer/correction_completed

### 2. **Testar Envio de Emails**

```ruby
# No console Rails (rails console)

# Teste 1: Notificação de Simulado
user = User.first
simulation = Simulation.first
SimulationMailer.new_simulation_assigned(user, simulation).deliver_now

# Teste 2: Notificação de Correção
correction = Correction.first
CorrectionMailer.correction_completed(correction.answer.attempt.user, correction).deliver_now
```

### 3. **Testar Jobs em Background**

```ruby
# No console Rails
SimulationNotificationJob.perform_now(simulation_id)
CorrectionNotificationJob.perform_now(correction_id)
```

## 🔄 Como o Sistema Funciona

### Fluxo de Notificação de Simulado

1. **Professor cria simulado** → `SimulationsController#create`
2. **Sistema associa grupos** ao simulado
3. **Job é enfileirado** → `SimulationNotificationJob.perform_later`
4. **Job executa em background**:
   - Busca todos os usuários dos grupos
   - Envia email para cada usuário
   - Cria notificação no sistema
   - Registra logs

### Fluxo de Notificação de Correção

1. **Professor cria/atualiza correção** → `CorrectionsController#create/update`
2. **Job é enfileirado** → `CorrectionNotificationJob.perform_later`
3. **Job executa em background**:
   - Busca o estudante da resposta
   - Envia email com detalhes da correção
   - Cria notificação no sistema
   - Registra logs

## 📱 Templates de Email

### Características dos Templates

- **Responsivos**: Funcionam bem em desktop e mobile
- **Profissionais**: Design limpo e moderno
- **Informativos**: Contêm todas as informações necessárias
- **Branded**: Identidade visual do Uniquest
- **Acessíveis**: Versões HTML e texto simples

### Personalização

Os templates estão em:
- `app/views/simulation_mailer/`
- `app/views/correction_mailer/`

Você pode personalizar:
- Cores e estilos CSS
- Conteúdo das mensagens
- Layout e estrutura
- Informações exibidas

## 🚀 Monitoramento

### Logs

O sistema registra logs detalhados:

```ruby
# Logs de sucesso
Rails.logger.info "Email enviado para #{user.email} sobre simulado #{simulation.title}"

# Logs de erro
Rails.logger.error "Erro ao enviar email para #{user.email}: #{e.message}"
```

### Verificação de Entrega

Para monitorar entregas em produção:
1. Verifique os logs do Render
2. Configure webhooks do provedor de email
3. Monitore bounces e reclamações

## ⚡ Performance

### Jobs em Background

- Emails são enviados de forma **assíncrona**
- Não bloqueia a resposta da API
- Usa **Solid Queue** em produção
- Retry automático em caso de falha

### Otimizações

- **Batch processing**: Múltiplos usuários processados eficientemente
- **Error handling**: Falhas não interrompem o processo
- **Logging**: Rastreamento completo para debugging

## 🔒 Segurança

### Boas Práticas Implementadas

- **Variáveis de ambiente** para credenciais
- **Validação de dados** antes do envio
- **Rate limiting** implícito via jobs
- **Escape de HTML** nos templates
- **SSL/TLS** obrigatório em produção

### Proteções

- Emails só são enviados para usuários válidos
- Conteúdo é sanitizado
- Logs não expõem informações sensíveis

## 🆘 Troubleshooting

### Problemas Comuns

1. **Emails não chegam**:
   - Verifique configurações SMTP
   - Confirme variáveis de ambiente
   - Verifique logs de erro

2. **Templates quebrados**:
   - Teste os previews
   - Verifique sintaxe ERB
   - Confirme dados de teste

3. **Jobs não executam**:
   - Verifique se Solid Queue está rodando
   - Confirme configuração do Active Job
   - Monitore logs de jobs

### Comandos Úteis

```bash
# Verificar jobs na fila
rails console
> SolidQueue::Job.all

# Limpar fila de jobs
> SolidQueue::Job.delete_all

# Executar job manualmente
> SimulationNotificationJob.perform_now(simulation_id)
```

## 📈 Próximos Passos

### Melhorias Futuras

- [ ] Templates personalizáveis por instituição
- [ ] Agendamento de emails
- [ ] Relatórios de entrega
- [ ] Integração com push notifications
- [ ] Preferências de notificação por usuário
- [ ] Templates multilíngues

### Integrações Possíveis

- **Analytics**: Google Analytics para emails
- **A/B Testing**: Testar diferentes templates
- **Segmentação**: Emails personalizados por perfil
- **Automação**: Sequências de emails educacionais
