class SubjectsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_subject, only: [ :show, :destroy ]

  def index
    @subjects = Subject.all.order(:name)
    render json: subjects_json(@subjects)
  end

  def show
    render json: subject_json(@subject)
  end

  def create
    @subject = Subject.new(subject_params)

    if @subject.save
      render json: subject_json(@subject), status: :created
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
    @subject = Subject.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Matéria não encontrada" }, status: :not_found
  end

  def subject_params
    params.require(:subject).permit(:name)
  end

  def subject_json(subject)
    {
      id: subject.id.to_s,
      name: subject.name,
      created_at: subject.created_at,
      updated_at: subject.updated_at
    }
  end

  def subjects_json(subjects)
    subjects.map { |subject| subject_json(subject) }
  end
end
