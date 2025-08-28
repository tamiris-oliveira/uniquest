class UsersController < ApplicationController
  before_action :authenticate_request!, only: %i[show update destroy index]

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
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
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

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :avatar, :course_id)
  end
  
  def user_with_course_json(user)
    user.attributes.merge(
      course: user.course ? {
        id: user.course.id,
        name: user.course.name,
        code: user.course.code
      } : nil
    )
  end
end
