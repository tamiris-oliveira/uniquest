class UsersController < ApplicationController
  before_action :authenticate_request!, only: %i[show update destroy index]
  before_action :authenticate_for_elevated_roles, only: [:create]

  def index
    users = User.includes(:course)
    
    # Filtrar por curso se especificado
    if params[:course_id].present?
      users = users.where(course_id: params[:course_id])
    end
    
    # Filtrar por role se especificado
    if params[:role].present?
      users = users.where(role: params[:role])
    end
    
    # Busca por nome se especificado
    if params[:search].present?
      users = users.where('name ILIKE ?', "%#{params[:search]}%")
    end
    
    render json: users.map { |user| user_with_course_json(user) }
  end

  def create
    requested_role = user_params[:role].to_i
    
    # Verificar permissões para criação de contas com roles elevados
    if requested_role > 0 # teacher, admin ou super_admin
      # Se chegou até aqui, @current_user já foi autenticado pelo before_action
      
      # Super Admin pode criar Admins (role 2) e outros Super Admins (role 3)
      if (requested_role == 2 || requested_role == 3) && @current_user.super_admin?
        # Permitido: Super Admin criando Admin ou Super Admin
      else
        # Bloquear outras tentativas (incluindo teachers e outros casos)
        render json: { 
          error: "Você não tem permissão para criar contas com este nível de acesso",
          message: "Para se tornar professor, registre-se como aluno e solicite upgrade da conta"
        }, status: :forbidden
        return
      end
    end
    
    # Se chegou até aqui, pode criar com o role solicitado (ou 0 se não especificado)
    final_role = requested_role > 0 ? requested_role : 0
    user_attributes = user_params.merge(role: final_role)
    
    # Se Super Admin está criando um Admin, aprova automaticamente
    if @current_user&.super_admin? && final_role == 2
      user_attributes.merge!(
        approval_status: :approved,
        approved_by: @current_user.id,
        approved_at: Time.current
      )
    end
    
    user = User.new(user_attributes)
    if user.save
      render json: user_with_course_json(user), status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: user_with_course_json(@current_user)
  end

  def update
    if @current_user.update(user_params)
      render json: user_with_course_json(@current_user)
    else
      render json: { errors: @current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  

  def destroy
    @current_user.destroy!
    render json: { message: "Usuário excluído com sucesso" }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: "Falha ao excluir o usuário." }, status: :unprocessable_entity
  end

  private
  
  def authenticate_for_elevated_roles
    # Só autentica se estiver tentando criar conta com role > 0
    if params[:user] && params[:user][:role].to_i > 0
      authenticate_request!
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :avatar, :course_id)
  end
  
  def user_with_course_json(user)
    {
      id: user.id.to_s,
      name: user.name,
      email: user.email,
      role: user.role,
      avatar: user.avatar,
      course_id: user.course_id&.to_s,
      created_at: user.created_at,
      updated_at: user.updated_at,
      course: user.course ? {
        id: user.course.id.to_s,
        name: user.course.name,
        code: user.course.code
      } : nil
    }
  end
end
