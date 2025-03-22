class SimulationsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_simulation, only: %i[show update destroy]

  def index
    render json: Simulation.all
  end

  def create
    simulation = Simulation.new(simulation_params)
    if simulation.save
      render json: simulation, status: :created, location: simulation
    else
      render json: { errors: simulation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: @simulation
  end

  def update
    if @simulation.update(simulation_params)
      render json: @simulation
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
    @simulation = Simulation.find_by(id: params[:id])
    render json: { error: "Simulação não encontrada." }, status: :not_found unless @simulation
  end

  def simulation_params
    params.require(:simulation).permit(:title, :description, :creation_date, :deadline, :user_id, :group_id)
  end
end
