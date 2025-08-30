class QuestionsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_question, only: [ :show, :update, :destroy ]

  def index
    begin
      # Filtrar questões baseado no curso do usuário atual
      if @current_user&.course_id.present?
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
    rescue => e
      Rails.logger.error "Erro no QuestionsController#index: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Erro interno do servidor", details: e.message }, status: :internal_server_error
    end
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
    @question = Question.includes(:alternatives, user: :course).find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Questão não encontrada" }, status: :not_found
  end

  def question_params
    params.require(:question).permit(:statement, :question_type, :justification, :user_id, :subject_id, alternatives_attributes: [ :id, :text, :correct, :_destroy ])
  end
  
  def question_with_user_json(question)
    {
      id: question.id.to_s,
      statement: question.statement,
      question_type: question.question_type,
      justification: question.justification,
      subject_id: question.subject_id.to_s,
      created_at: question.created_at,
      updated_at: question.updated_at,
      user: question.user ? {
        id: question.user.id.to_s,
        name: question.user.name,
        course: question.user.course ? {
          id: question.user.course.id.to_s,
          name: question.user.course.name,
          code: question.user.course.code
        } : nil
      } : nil,
      alternatives: question.alternatives.map do |alt|
        {
          id: alt.id.to_s,
          text: alt.text,
          correct: alt.correct
        }
      end
    }
  end
end
