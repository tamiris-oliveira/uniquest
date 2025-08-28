class GroupsController < ApplicationController
  before_action :authenticate_request!

  def index
    # Filtrar grupos baseado no curso do usuário atual
    if @current_user.course_id.present?
      # Buscar grupos que tenham pelo menos um usuário do mesmo curso
      groups = Group.joins(:users)
                   .where(users: { course_id: @current_user.course_id })
                   .distinct
    else
      # Se o usuário não tem curso definido, mostrar todos os grupos
      groups = Group.all
    end

    # Aplicar filtros adicionais
    params.each do |key, value|
      if Group.column_names.include?(key) && value.present?
        groups = groups.where("groups.#{key} LIKE ?", "%#{value}%")
      end
    end

    # Incluir informações dos usuários com seus cursos
    groups = groups.includes(users: :course)
    
    render json: groups.map { |group| group_with_users_json(group) }
  end



  def create
    users = User.includes(:course).where(id: params[:group][:users_id])

    if users.empty?
      return render json: { error: "Pelo menos um usuário válido é necessário." }, status: :unprocessable_entity
    end

    # Verificar se todos os usuários são do mesmo curso (se o usuário atual tem curso)
    if @current_user.course_id.present?
      different_course_users = users.where.not(course_id: @current_user.course_id)
      if different_course_users.any?
        return render json: { 
          error: "Todos os usuários devem ser do mesmo curso (#{@current_user.course&.name})." 
        }, status: :unprocessable_entity
      end
    end

    group = Group.new(group_params.except(:users_id))

    if group.save
      group.users = users
      render json: group_with_users_json(group), status: :created
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    group = find_group
    return unless group   # para evitar continuar se for nil
  
    render json: group_with_users_json(group)
  end
  

  def update
    group = find_group
    return unless group

    if group.update(group_params)
      if params.dig(:group, :users_id).present?
        users = User.includes(:course).where(id: params[:group][:users_id])
        
        # Verificar se todos os usuários são do mesmo curso (se o usuário atual tem curso)
        if @current_user.course_id.present?
          different_course_users = users.where.not(course_id: @current_user.course_id)
          if different_course_users.any?
            return render json: { 
              error: "Todos os usuários devem ser do mesmo curso (#{@current_user.course&.name})." 
            }, status: :unprocessable_entity
          end
        end
        
        group.users = users
      end
      render json: group_with_users_json(group)
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    group = find_group
    return unless group

    group.users.clear
    group.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: "Falha ao excluir o grupo." }, status: :unprocessable_entity
  end

  def add_user
    group = find_group
    user = User.includes(:course).find_by(id: params[:user_id])
    return render json: { error: "Usuário não encontrado." }, status: :not_found unless user

    # Verificar se o usuário é do mesmo curso (se o usuário atual tem curso)
    if @current_user.course_id.present? && user.course_id != @current_user.course_id
      return render json: { 
        error: "O usuário deve ser do mesmo curso (#{@current_user.course&.name})." 
      }, status: :unprocessable_entity
    end

    group.users << user unless group.users.include?(user)
    render json: group_with_users_json(group)
  end

  private

  def find_group
    group = Group.includes(users: :course).find_by(id: params[:id])
    unless group
      render json: { error: "Grupo não encontrado." }, status: :not_found
      return nil
    end
  
    group
  end
  
  def group_params
    params.require(:group).permit(:name, :invite_code, :creator_id, :users_id)
  end
  
  def group_with_users_json(group)
    group.attributes.merge(
      users: group.users.map do |user|
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          course: user.course ? {
            id: user.course.id,
            name: user.course.name,
            code: user.course.code
          } : nil
        }
      end
    )
  end
end
