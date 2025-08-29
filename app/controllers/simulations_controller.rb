class SimulationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_simulation, only: %i[show update destroy groups questions assign_groups assign_questions]

  def index
    user_group_ids = @current_user.groups.pluck(:id)
  
    simulations = Simulation
      .includes(:groups, :questions)
      .left_joins(:groups)
      .where("simulations.user_id = :user_id OR groups.id IN (:group_ids)",
             user_id: @current_user.id,
             group_ids: user_group_ids)
      .distinct
  
    params.each do |key, value|
      if Simulation.column_names.include?(key) && value.present?
        simulations = simulations.where("simulations.#{key} LIKE ?", "%#{value}%")
      end
    end
  
    render json: simulations.map { |sim| simulation_json(sim) }
  end  
  

  def groups
    render json: @simulation.groups
  end

  def questions
    questions = @simulation.questions.includes(:alternatives).select(:id, :statement, :justification, :question_type)
    render json: questions.map { |q| question_with_alternatives_json(q) }
  end


  def question_with_alternatives_json(question)
    {
      id: question.id.to_s,
      statement: question.statement,
      justification: question.justification,
      question_type: question.question_type,
      alternatives: question.alternatives.map do |alt|
        {
          id: alt.id.to_s,
          text: alt.text,
          correct: alt.correct
        }
      end
    }
  end
  
  
  def assign_groups
    groups = Group.where(id: params[:group_ids])
    @simulation.groups = groups
    render json: { message: "Grupos atualizados com sucesso." }, status: :ok
  end

  def assign_questions
    questions = Question.where(id: params[:question_ids])
    @simulation.questions = questions
    render json: { message: "Questões atualizadas com sucesso." }, status: :ok
  end


  def create
    simulation = Simulation.new(simulation_params.except(:group_ids, :question_ids))
    if simulation.save
      # Associa todos os grupos através da tabela group_simulations
      if simulation_params[:group_ids].present?
        simulation.groups = Group.where(id: simulation_params[:group_ids])
      end
      if simulation_params[:question_ids].present?
        simulation.questions = Question.where(id: simulation_params[:question_ids])
      end
      render_simulation(simulation, status: :created)
    else
      render json: { errors: simulation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render_simulation(@simulation)
  end

  def update
    if @simulation.update(simulation_params.except(:group_ids, :question_ids))
      # Associa todos os grupos através da tabela group_simulations
      if simulation_params[:group_ids].present?
        @simulation.groups = Group.where(id: simulation_params[:group_ids])
      end
      if simulation_params[:question_ids].present?
        @simulation.questions = Question.where(id: simulation_params[:question_ids])
      end
      render_simulation(@simulation)
    else
      render json: { errors: @simulation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @simulation.destroy!
    render json: { message: "Simulação excluída com sucesso" }, status: :ok
  rescue ActiveRecord::RecordNotDestroyed
    render json: { error: "Falha ao excluir a simulação." }, status: :unprocessable_entity
  end

  def with_attempts_answers
    if @current_user.role == 1 
      simulations = Simulation
                    .where(user: @current_user)
                    .includes(attempts: { user: {}, answers: [:question, :corrections] })

      render json: simulations.as_json(
        include: {
          attempts: {
            include: {
              user: { only: [:id, :name] },
              answers: {
                include: {
                  question: { only: [:id, :statement, :question_type] },
                  corrections: { only: [:id, :grade, :feedback, :user_id] }
                }
              }
            },
            only: [:id, :attempt_date, :final_grade]
          }
        },
        only: [:id, :title]
      )

    else
      # Usuário comum: pegar todas as tentativas dele, com simulados e respostas
      attempts = Attempt
                 .where(user: @current_user)
                 .includes(:simulation, answers: [:question, :corrections])

      # Agrupar por simulado
      grouped = attempts.group_by(&:simulation)

      # Construir JSON customizado
      result = grouped.map do |simulation, attempts|
        {
          id: simulation.id,
          title: simulation.title,
          attempts: attempts.map do |attempt|
            {
              id: attempt.id,
              attempt_date: attempt.attempt_date,
              user: {
                id: @current_user.id,
                name: @current_user.name
              },
              answers: attempt.answers.as_json(
                include: {
                  question: { only: [:id, :statement, :question_type] },
                  corrections: { only: [:id, :grade, :feedback, :user_id] }
                }
              )
            }
          end
        }
      end

      render json: result
    end
  end

  private

  def set_simulation
    @simulation = Simulation.includes(:groups, :questions).find_by(id: params[:id].to_i)
    return if @simulation

    render json: { error: "Simulação não encontrada." }, status: :not_found
  end

  def simulation_params
    params.require(:simulation).permit(
      :title, :description, :creation_date, :deadline, :time_limit, :max_attempts, :user_id,
      group_ids: [], question_ids: []
    )
  end

  def simulation_json(simulation)
    {
      id: simulation.id.to_s,
      title: simulation.title,
      description: simulation.description,
      creation_date: simulation.creation_date,
      deadline: simulation.deadline,
      time_limit: simulation.time_limit,
      max_attempts: simulation.max_attempts,
      user_id: simulation.user_id.to_s,
      created_at: simulation.created_at,
      updated_at: simulation.updated_at,
      groups: simulation.groups.map { |g| { id: g.id.to_s, name: g.name, invite_code: g.invite_code } },
      questions: simulation.questions.includes(:alternatives).map do |q|
        question_with_alternatives_json(q)
      end
    }
  end


  def render_simulation(simulation, status: :ok)
    render json: simulation_json(simulation), status: status
  end
end