class UserApprovalsController < ApplicationController
  before_action :authenticate_request!
  before_action :require_admin_or_super_admin!, except: [:request_teacher_role]
  before_action :set_user, only: [:approve, :reject]

  # GET /user_approvals
  # Lista usuários pendentes de aprovação
  def index
    @pending_users = User.pending_approval.includes(:course).order(created_at: :desc)
    
    if @current_user.super_admin?
      # Super admins veem todos os usuários pendentes
      # Não precisa filtrar nada
    elsif @current_user.admin?
      # Admins só veem professores do mesmo curso
      @pending_users = @pending_users.where(role: 1) # Apenas professores
      @pending_users = @pending_users.where(course_id: @current_user.course_id) if @current_user.course_id.present?
    else
      # Fallback: não deveria chegar aqui devido ao before_action
      @pending_users = @pending_users.none
    end
    
    render json: @pending_users.map { |user| user_approval_json(user) }
  end

  # POST /user_approvals/:id/approve
  # Aprova um usuário
  def approve
    # Verificar permissões específicas usando o método do modelo
    unless @current_user.can_approve_user?(@user)
      error_message = if @user.admin?
                        "Apenas Super Admins podem aprovar Administradores"
                      elsif @user.teacher? && @current_user.admin?
                        if @current_user.course_id.blank?
                          "Admin deve estar associado a um curso para aprovar professores"
                        else
                          "Você só pode aprovar professores do seu curso"
                        end
                      else
                        "Você não tem permissão para aprovar este usuário"
                      end
      
      render json: { error: error_message }, status: :forbidden
      return
    end
    
    begin
      @user.approve!(@current_user)
      
      # Notificar o usuário sobre aprovação
      role_name = case @user.role
      when 1 then 'professor'
      when 2 then 'administrador'
      when 3 then 'super administrador'
      else 'usuário'
      end
      
      Notification.create!(
        user: @user,
        message: "Sua conta foi aprovada! Agora você pode acessar o sistema como #{role_name}.",
        viewed: false,
        send_date: Time.current
      )
      
      render json: { 
        message: "Usuário aprovado com sucesso",
        user: user_approval_json(@user)
      }, status: :ok
    rescue => e
      render json: { error: "Erro ao aprovar usuário: #{e.message}" }, status: :unprocessable_entity
    end
  end

  # POST /user_approvals/:id/reject
  # Rejeita um usuário (apenas admins)
  def reject
    begin
      @user.reject!(@current_user)
      
      # Notificar o usuário sobre rejeição
      Notification.create!(
        user: @user,
        message: "Sua solicitação para se tornar #{@user.teacher? ? 'professor' : 'administrador'} foi rejeitada. Entre em contato com o suporte para mais informações.",
        viewed: false,
        send_date: Time.current
      )
      
      render json: { 
        message: "Usuário rejeitado",
        user: user_approval_json(@user)
      }, status: :ok
    rescue => e
      render json: { error: "Erro ao rejeitar usuário: #{e.message}" }, status: :unprocessable_entity
    end
  end

  # POST /user_approvals/request_teacher_role
  # Permite que aluno solicite se tornar professor
  def request_teacher_role
    unless @current_user.student?
      render json: { error: "Apenas alunos podem solicitar se tornar professor" }, status: :forbidden
      return
    end
    
    if @current_user.teacher_pending_approval?
      render json: { error: "Você já tem uma solicitação pendente" }, status: :unprocessable_entity
      return
    end
    
    begin
      @current_user.update!(
        role: 1, # teacher
        approval_status: :pending
      )
      
      # Notificar admins do mesmo curso e super admins
      admins_to_notify = []
      
      # Super admins sempre são notificados
      admins_to_notify += User.super_admins.approved.to_a
      
      # Admins do mesmo curso (se o usuário tiver curso)
      if @current_user.course_id.present?
        admins_to_notify += User.admins.approved.where(course_id: @current_user.course_id).to_a
      else
        # Se não tiver curso, notificar todos os admins
        admins_to_notify += User.admins.approved.to_a
      end
      
      admins_to_notify.uniq.each do |admin|
        Notification.create!(
          user: admin,
          message: "#{@current_user.name} solicitou se tornar professor#{@current_user.course&.name ? " no curso #{@current_user.course.name}" : ""}",
          viewed: false,
          send_date: Time.current
        )
      end
      
      render json: { 
        message: "Solicitação enviada com sucesso! Aguarde a aprovação de um administrador.",
        user: user_approval_json(@current_user)
      }, status: :ok
    rescue => e
      render json: { error: "Erro ao enviar solicitação: #{e.message}" }, status: :unprocessable_entity
    end
  end

  private

  def require_admin_or_super_admin!
    unless @current_user&.can_approve_users?
      render json: { error: "Acesso negado. Apenas administradores podem gerenciar aprovações." }, status: :forbidden
    end
  end

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
  end

  def user_approval_json(user)
    {
      id: user.id.to_s,
      name: user.name,
      email: user.email,
      role: user.role,
      role_name: case user.role
                 when 0 then 'Aluno'
                 when 1 then 'Professor' 
                 when 2 then 'Administrador'
                 when 3 then 'Super Administrador'
                 else 'Usuário'
                 end,
      approval_status: user.approval_status,
      course: user.course ? {
        id: user.course.id.to_s,
        name: user.course.name,
        code: user.course.code
      } : nil,
      created_at: user.created_at,
      approved_at: user.approved_at,
      approved_by: user.approved_by_user ? {
        id: user.approved_by_user.id.to_s,
        name: user.approved_by_user.name
      } : nil
    }
  end
end
