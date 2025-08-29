class AttemptsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_attempt, only: [:show, :update, :destroy, :submit_answers]

  def index
    attempts = Attempt.includes(:user, simulation: [], answers: [question: :alternatives, corrections: []]).all
    
    # Filtrar por simulation_id se fornecido
    if params[:simulation_id].present?
      attempts = attempts.where(simulation_id: params[:simulation_id])
    end
    
    # Filtrar por user_id se fornecido
    if params[:user_id].present?
      attempts = attempts.where(user_id: params[:user_id])
    end
  
        render json: attempts.map { |attempt| attempt_json(attempt) }
  end
  
  

  def show
    render json: attempt_json(@attempt)
  end

  def create
    simulation = Simulation.find_by(id: params[:attempt][:simulation_id].to_i)
    return render json: { error: "Simulado não encontrado." }, status: :not_found unless simulation

    if simulation.max_attempts.present?
      current_attempts = Attempt.where(user: @current_user, simulation: simulation).count
      if current_attempts >= simulation.max_attempts || Time.current > simulation.deadline
        return render json: { error: "Número máximo de tentativas atingido ou simulado venceu." }, status: :forbidden
      end
    end

    @attempt = Attempt.new(
      user: @current_user,
      simulation: simulation,
      attempt_date: Time.current
    )

    if @attempt.save
      render json: @attempt, status: :created
    else
      render json: @attempt.errors, status: :unprocessable_entity
    end
  end

  def update
    if @attempt.update(attempt_params)
      render json: @attempt
    else
      render json: @attempt.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @attempt.destroy
  end

  def submit_answers
    answers_params = params.require(:answers)
  
    unless answers_params.is_a?(Array)
      return render json: { error: "Formato inválido. Esperado array de respostas." }, status: :bad_request
    end
  
    answers_params.each do |param|
      question = Question.find(param[:question_id].to_i)
      is_correct = nil
      grade = nil
  
      if question.question_type == "Objetiva"
        correct_alternative = question.alternatives.find_by(correct: true)
        is_correct = normalize_text(correct_alternative&.text) == normalize_text(param[:student_answer])
        grade = is_correct ? 10.0 : 0.0  # Nota exemplo: 1 para correta, 0 para incorreta
      end
  
      answer = Answer.find_or_initialize_by(attempt: @attempt, question: question)
      answer.student_answer = param[:student_answer]
      answer.correct = is_correct
      answer.save!
  
      Correction.create!(
        answer: answer,
        user_id: @current_user.id,
        grade: grade,
        feedback: (is_correct ? "Resposta correta automaticamente." : "Resposta incorreta."),
        correction_date: Time.current
      )
    end
  
    update_final_grade
  
    render json: { message: "Respostas enviadas com sucesso, correções criadas e nota final atualizada." }, status: :created
  
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  rescue ActionController::ParameterMissing
    render json: { error: "Parâmetro answers obrigatório." }, status: :bad_request
  end
  
  private
  
  def normalize_text(text)
    text.to_s.strip.downcase
  end
  
  def update_final_grade
    # pega todas as correções da tentativa que possuem nota
    corrections_with_grade = Correction.joins(:answer).where(answers: { attempt_id: @attempt.id }).where.not(grade: nil)
    return if corrections_with_grade.empty?
  
    # soma e média das notas
    total_grade = corrections_with_grade.sum(:grade)
    count = corrections_with_grade.count
    final_grade = (total_grade / count.to_f).round(2)
  
    # atualiza a tentativa com a nota final
    @attempt.update(final_grade: final_grade)
  end
  
  

  def set_attempt
    @attempt = Attempt.find(params[:id].to_i)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Tentativa não encontrada." }, status: :not_found
  end

  def attempt_params
    params.require(:attempt).permit(:simulation_id)
  end

  def attempt_json(attempt)
    {
      id: attempt.id.to_s,
      attempt_date: attempt.attempt_date,
      final_grade: attempt.final_grade,
      user: {
        id: attempt.user.id.to_s,
        name: attempt.user.name,
        email: attempt.user.email
      },
      simulation: {
        id: attempt.simulation.id.to_s,
        title: attempt.simulation.title,
        deadline: attempt.simulation.deadline
      },
      answers: attempt.answers.map do |answer|
        last_correction = answer.corrections.order(correction_date: :desc).first

        {
          id: answer.id.to_s,
          student_answer: answer.student_answer,
          correct: answer.correct,
          question: {
            id: answer.question.id.to_s,
            statement: answer.question.statement,
            question_type: answer.question.question_type,
            alternatives: answer.question.alternatives.map do |alt|
              {
                id: alt.id.to_s,
                text: alt.text,
                correct: alt.correct
              }
            end
          },
          correction: last_correction ? {
            id: last_correction.id.to_s,
            grade: last_correction.grade,
            feedback: last_correction.feedback,
            correction_date: last_correction.correction_date
          } : nil
        }
      end
    }
  end
end
