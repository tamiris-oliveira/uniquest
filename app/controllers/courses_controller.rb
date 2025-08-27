class CoursesController < ApplicationController
  before_action :set_course, only: [:show]
  
  # GET /courses
  # Lista todos os cursos com contagem de usuários
  def index
    @courses = Course.includes(:users)
                    .by_name
                    .select('courses.*, COUNT(users.id) as users_count')
                    .left_joins(:users)
                    .group('courses.id')
    
    respond_to do |format|
      format.json { render json: courses_json(@courses) }
      format.html
    end
  end

  # GET /courses/:id
  # Mostra um curso específico com seus usuários
  def show
    @users = @course.users.by_name.includes(:groups, :simulations)
    
    respond_to do |format|
      format.json { render json: course_json(@course, @users) }
      format.html
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
    
    @users = @users.by_name.page(params[:page])
    
    respond_to do |format|
      format.json { render json: users_json(@users) }
      format.html { render 'users/index' }
    end
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
    
    respond_to do |format|
      format.json { render json: stats }
      format.html
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
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
