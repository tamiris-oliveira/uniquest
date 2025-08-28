class SubjectsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_subject, only: [ :show, :destroy ]

  def index
    @subjects = Subject.all.order(:name)
    render json: @subjects
  end

  def show
    render json: @subject
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      render json: @subject, status: :created
    else
      render json: { errors: @subject.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @subject.questions.exists?
      render json: { error: "Não é possível excluir uma matéria com questões associadas." }, status: :forbidden
    else
      @subject.destroy
      render json: { message: "Matéria excluída com sucesso." }, status: :ok
    end
  end

  private

  def set_subject
    @subject = Subject.find(params[:id])
  end

  def subject_params
    params.require(:subject).permit(:name)
  end
end
