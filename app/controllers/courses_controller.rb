class CoursesController < ApplicationController
  before_action :authenticate_request!, except: [:index]
  before_action :set_course, only: [:show, :update]
  before_action :authorize_course_access!, only: [:show, :update]
  
  # GET /courses
  # Lista cursos baseado no perfil do usuário
  def index
    begin
      # Primeiro, vamos testar sem a query complexa
      @courses = accessible_courses
      
      # Se chegou até aqui, vamos tentar a query complexa
      @courses = @courses.left_joins(:users)
                        .select('courses.*, COUNT(users.id) as users_count')
                        .group('courses.id')
                        .order(:name)
      
      render json: courses_json(@courses)
    rescue => e
      # Debug temporário - remover depois
      courses_count = begin
        Course.count
      rescue
        "N/A"
      end
      
      render json: { 
        error: "Debug: #{e.message}", 
        backtrace: e.backtrace.first(5),
        courses_count: courses_count
      }, status: 500
    end
  end

  # GET /courses/:id
  # Mostra um curso específico com seus usuários
  def show
    @users = @course.users.by_name.includes(:groups, :simulations)
    
    render json: course_json(@course, @users)
  end

  # POST /courses
  # Cria um novo curso (apenas superadmin)
  def create
    unless @current_user.role == 2 # Apenas superadmin
      render json: { error: "Não autorizado" }, status: :forbidden
      return
    end
    
    @course = Course.new(course_params)
    
    if @course.save
      render json: course_json(@course), status: :created
    else
      render json: { errors: @course.errors }, status: :unprocessable_entity
    end
  end

  # PUT /courses/:id
  # Atualiza um curso existente
  def update
    if @course.update(course_params)
      render json: course_json(@course)
    else
      render json: { errors: @course.errors }, status: :unprocessable_entity
    end
  end

  # GET /courses/:id/users
  # Lista usuários de um curso específico com filtros
  def users
    @course = Course.find(params[:id])
    @users = @course.users.includes(:groups, :simulations)
    
    # Filtros opcionais
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.joins(:groups).where(groups: { id: params[:group_id] }) if params[:group_id].present?
    
    @users = @users.by_name
    
    render json: users_json(@users)
  end

  # GET /courses/:id/statistics
  # Estatísticas do curso
  def statistics
    @course = Course.find(params[:id])
    
    stats = {
      total_users: @course.users.count,
      students_count: @course.users.students.count,
      teachers_count: @course.users.teachers.count,
      groups_count: @course.groups.count,
      simulations_count: @course.simulations.count,
      users_by_role: @course.users.group(:role).count
    }
    
    render json: stats
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :code, :description)
  end

  # Retorna cursos acessíveis baseado no perfil do usuário
  def accessible_courses
    # Se não há usuário autenticado, retorna todos os cursos (acesso público)
    return Course.all unless @current_user
    
    case @current_user.role
    when 2 # Superadmin - vê todos os cursos
      Course.all
    when 1 # Professor - vê apenas seu curso
      @current_user.course ? Course.where(id: @current_user.course_id) : Course.none
    else # Estudante - vê apenas seu curso
      @current_user.course ? Course.where(id: @current_user.course_id) : Course.none
    end
  end

  # Verifica se o usuário pode acessar o curso específico
  def authorize_course_access!
    case @current_user.role
    when 2 # Superadmin - acesso total
      return true
    when 1 # Professor - apenas seu curso
      unless @current_user.course_id == @course.id
        render json: { error: "Não autorizado" }, status: :forbidden
        return false
      end
    else # Estudante - apenas visualização do seu curso
      unless @current_user.course_id == @course.id
        render json: { error: "Não autorizado" }, status: :forbidden
        return false
      end
    end
  end

  def courses_json(courses)
    courses.map do |course|
      {
        id: course.id,
        name: course.name,
        code: course.code,
        description: course.description,
        users_count: course.users_count || 0,
        created_at: course.created_at
      }
    end
  end

  def course_json(course, users = nil)
    {
      id: course.id,
      name: course.name,
      code: course.code,
      description: course.description,
      users_count: course.users.count,
      groups_count: course.groups.count,
      simulations_count: course.simulations.count,
      users: users ? users_json(users) : nil,
      created_at: course.created_at,
      updated_at: course.updated_at
    }
  end

  def users_json(users)
    users.map do |user|
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        course_name: user.course_name,
        groups_count: user.groups.count,
        simulations_count: user.simulations.count,
        created_at: user.created_at
      }
    end
  end
end
