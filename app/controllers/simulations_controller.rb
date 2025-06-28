class SimulationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_simulation, only: %i[show update destroy groups assign_groups]

  def index
    simulations = Simulation.includes(:groups, :questions).all
    render json: simulations.map { |sim| simulation_json(sim) }
  end

  def groups
    render json: @simulation.groups
  end

  def assign_groups
    groups = Group.where(id: params[:group_ids])
    @simulation.groups = groups
    render json: { message: "Grupos atualizados com sucesso." }, status: :ok
  end

  def create
    simulation = Simulation.new(simulation_params.except(:group_ids))
    if simulation.save
      simulation.groups = Group.where(id: simulation_params[:group_ids])
      render_simulation(simulation, status: :created)
    else
      render json: { errors: simulation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render_simulation(@simulation)
  end

  def update
    if @simulation.update(simulation_params.except(:group_ids))
      if simulation_params[:group_ids]
        @simulation.groups = Group.where(id: simulation_params[:group_ids])
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

  private

  def set_simulation
    @simulation = Simulation.includes(:groups, :questions).find_by(id: params[:id])
    return if @simulation

    render json: { error: "Simulação não encontrada." }, status: :not_found
  end

  def simulation_params
    params.require(:simulation).permit(:title, :description, :creation_date, :deadline, :user_id, group_ids: [])
  end

  def simulation_json(simulation)
    simulation.as_json(
      include: [
        { groups: { only: [ :id, :name, :invite_code ] } },
        { questions: { only: [ :id, :title, :content ] } }
      ]
    )
  end

  def render_simulation(simulation, status: :ok)
    render json: simulation_json(simulation), status: status
  end
end
