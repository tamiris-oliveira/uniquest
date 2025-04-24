class GroupsController < ApplicationController
  before_action :authenticate_request!

  def index
    groups = Group.all

    params.each do |key, value|
      if Group.column_names.include?(key) && value.present?
        groups = groups.where("#{key} LIKE ?", "%#{value}%")
      end
    end

    render json: groups
  end



  def create
    users = User.where(id: params[:group][:users_id])

    if users.empty?
      return render json: { error: "Pelo menos um usuário válido é necessário." }, status: :unprocessable_entity
    end

    group = Group.new(group_params.except(:users_id))

    if group.save
      group.users = users
      render json: group, include: :users, status: :created
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    group = find_group
    return unless group

    render json: group, include: :users
  end

  def update
    group = find_group
    return unless group

    if group.update(group_params)
      group.users = User.where(id: params[:group][:users_id]) if params.dig(:group, :users_id).present?
      render json: group, include: :users
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
    user = User.find_by(id: params[:user_id])
    return render json: { error: "Usuário não encontrado." }, status: :not_found unless user

    group.users << user unless group.users.include?(user)
    render json: group, include: :users
  end

  private

  def find_group
    group = Group.find_by(id: params[:id])
    return render json: { error: "Grupo não encontrado." }, status: :not_found unless group

    group
  end

  def group_params
    params.require(:group).permit(:name, :invite_code, :users_id)
  end
end
