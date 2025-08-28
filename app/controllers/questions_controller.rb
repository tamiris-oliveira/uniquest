class QuestionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_question, only: [ :show, :update, :destroy ]

  def index
    # Filtrar questões baseado no curso do usuário atual
    if @current_user.course_id.present?
      @questions = Question.includes(:alternatives, user: :course)
                          .joins(:user)
                          .where(users: { course_id: @current_user.course_id })
    else
      @questions = Question.includes(:alternatives, user: :course).all
    end
    
    # Aplicar filtros adicionais
    if params[:subject_id].present?
      @questions = @questions.where(subject_id: params[:subject_id])
    end
    
    if params[:question_type].present?
      @questions = @questions.where(question_type: params[:question_type])
    end
    
    if params[:search].present?
      @questions = @questions.where('statement ILIKE ?', "%#{params[:search]}%")
    end
    
    render json: @questions.map { |question| question_with_user_json(question) }
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      render json: @question.to_json(include: :alternatives), status: :created, location: question_url(@question)
    else
      render json: @question.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: question_with_user_json(@question)
  end

  def update
    if @question.update(question_params)
      render json: question_with_user_json(@question)
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @question.question_simulations.delete_all
  
      @question.destroy!
    end
  
    render json: { message: "Questão e relações excluídas com sucesso" }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed, ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  
  private

  def set_question
    @question = Question.includes(:alternatives, user: :course).find(params[:id])
  end

  def question_params
    params.require(:question).permit(:statement, :question_type, :justification, :user_id, :subject_id, alternatives_attributes: [ :id, :text, :correct, :_destroy ])
  end
  
  def question_with_user_json(question)
    question.attributes.slice('id', 'statement', 'question_type', 'justification', 'subject_id', 'created_at', 'updated_at').merge(
      user: question.user ? {
        id: question.user.id,
        name: question.user.name,
        course: question.user.course ? {
          id: question.user.course.id,
          name: question.user.course.name,
          code: question.user.course.code
        } : nil
      } : nil,
      alternatives: question.alternatives.map do |alt|
        alt.attributes.slice('id', 'text', 'correct')
      end
    )
  end
end
