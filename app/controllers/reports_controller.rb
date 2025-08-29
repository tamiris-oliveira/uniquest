class ReportsController < ApplicationController
  before_action :authenticate_request!
  before_action :authorize_teacher!, only: [:group_summary, :simulation_details, :groups_comparison]

  # --- ENDPOINTS PARA ALUNOS ---

  # GET /reports/student/performance_evolution
  def performance_evolution
    start_date, end_date = parse_period(params)
    return render_bad_request unless start_date && end_date

    render json: student_evolution_data(@current_user.id, start_date, end_date)
  end

  # GET /reports/student/subject_performance
  def subject_performance
    start_date, end_date = parse_period(params)
    return render_bad_request unless start_date && end_date

    render json: student_subject_data(@current_user.id, start_date, end_date)
  end


  # --- ENDPOINTS PARA PROFESSORES ---

  # GET /reports/teacher/group_summary/:group_id
  def group_summary
    group = Group.find_by(id: params[:group_id].to_i)
    return render_not_found("Grupo") unless group

    start_date, end_date = parse_period(params)
    return render_bad_request unless start_date && end_date

    render json: teacher_group_summary_data(group, start_date, end_date)
  end

  # GET /reports/teacher/simulation_details/:simulation_id
  def simulation_details
    simulation = Simulation.find_by(id: params[:simulation_id].to_i)
    return render_not_found("Simulado") unless simulation

    render json: teacher_simulation_data(simulation)
  end

  # GET /reports/teacher/groups_comparison
  def groups_comparison
    start_date, end_date = parse_period(params)
    return render_bad_request unless start_date && end_date

    # Considera grupos onde o professor é o criador. Ajuste se a lógica for outra.
    groups = Group.where(creator_id: @current_user.id)
    render json: teacher_groups_comparison_data(groups, start_date, end_date)
  end


  private

  # --- MÉTODOS DE DADOS (DATA METHODS) ---

  def student_evolution_data(user_id, start_date, end_date)
    attempts = Attempt.where(user_id: user_id)
                      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                      .order(:created_at)

    # O campo `final_grade` na tabela `attempts` é ideal para performance.
    # Se ele não for confiavel, a lógica de recálculo da controller original deve ser usada.
    labels = attempts.map { |a| a.created_at.strftime('%d/%m') }
    data = attempts.map { |a| a.final_grade || 0 }

    {
      labels: labels,
      datasets: [{
        label: "Nota Final",
        data: data
      }]
    }
  end

  def student_subject_data(user_id, start_date, end_date)
    # Calcula a taxa de acerto por matéria para questões objetivas
    subject_stats = Answer.joins(:question, :attempt)
      .where(attempts: { user_id: user_id, created_at: start_date.beginning_of_day..end_date.end_of_day })
      .where(questions: { question_type: 'Objetiva' })
      .group('questions.subject_id')
      .pluck(
        'questions.subject_id',
        Arel.sql('SUM(CASE WHEN answers.correct = true THEN 1 ELSE 0 END)'), # Contagem de corretas
        Arel.sql('COUNT(answers.id)') # Contagem total
      )

    # Mapeia IDs para nomes e calcula o percentual
    subject_names = Subject.where(id: subject_stats.map(&:first)).pluck(:id, :name).to_h
    
    performance_data = subject_stats.map do |subject_id, correct, total|
      accuracy = total > 0 ? ((correct.to_f / total) * 100).round(1) : 0
      { name: subject_names[subject_id] || "Indefinido", accuracy: accuracy }
    end.sort_by { |h| -h[:accuracy] } # Ordena da maior para a menor performance

    {
      labels: performance_data.map { |d| d[:name] },
      datasets: [{
        label: 'Taxa de Acerto (%)',
        data: performance_data.map { |d| d[:accuracy] }
      }]
    }
  end

  def teacher_group_summary_data(group, start_date, end_date)
    user_ids = group.users.pluck(:id)
    attempts = Attempt.where(user_id: user_ids)
                      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)

    # KPIs
    average_grade = attempts.average(:final_grade)&.round(2) || 0.0

    # Lógica para o Histograma de Notas
    bins = [0, 0, 0, 0, 0] # [0-20, 21-40, 41-60, 61-80, 81-100]
    attempts.pluck(:final_grade).each do |grade|
      g = grade.to_f
      if g <= 20; bins[0] += 1
      elsif g <= 40; bins[1] += 1
      elsif g <= 60; bins[2] += 1
      elsif g <= 80; bins[3] += 1
      else; bins[4] += 1
      end
    end

    {
      group_name: group.name,
      average_grade: average_grade,
      total_students: user_ids.size,
      total_attempts: attempts.size,
      grade_distribution: {
        labels: ["0-20", "21-40", "41-60", "61-80", "81-100"],
        datasets: [{ label: "Nº de Alunos", data: bins }]
      }
    }
  end

  def teacher_simulation_data(simulation)
    attempts = simulation.attempts.includes(:user)

    # Ranking
    ranking = attempts.order(final_grade: :desc).map do |attempt|
      { id: attempt.user.id.to_s, name: attempt.user.name, grade: attempt.final_grade&.round(2) || 0 }
    end

    # Questões mais difíceis
    question_stats = Answer.joins(:question)
      .where(attempt_id: attempts.pluck(:id), questions: { question_type: 'Objetiva' })
      .group('questions.id', 'questions.statement')
      .pluck(
        'questions.statement',
        Arel.sql('SUM(CASE WHEN answers.correct = false THEN 1 ELSE 0 END) * 100.0 / COUNT(answers.id)')
      )
      .sort_by { |_statement, error_rate| -error_rate }
      .first(5)
    
    {
      simulation_title: simulation.title,
      average_grade: attempts.average(:final_grade)&.round(2) || 0,
      student_ranking: ranking,
      most_difficult_questions: {
        labels: question_stats.map(&:first), # statements
        datasets: [{ label: 'Taxa de Erro (%)', data: question_stats.map(&:last) }] # error_rates
      }
    }
  end

  def teacher_groups_comparison_data(groups, start_date, end_date)
    comparison_data = groups.map do |group|
      user_ids = group.users.pluck(:id)
      avg = Attempt.where(user_id: user_ids)
                   .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                   .average(:final_grade)&.round(2) || 0.0
      { name: group.name, avg_grade: avg }
    end

    {
      labels: comparison_data.map { |d| d[:name] },
      datasets: [{
        label: "Nota Média",
        data: comparison_data.map { |d| d[:avg_grade] }
      }]
    }
  end

  # --- MÉTODOS DE APOIO (HELPERS) ---

  def authorize_teacher!
    render json: { error: "Acesso não autorizado." }, status: :forbidden unless @current_user.role == 1
  end

  def parse_date(date_str)
    Date.parse(date_str) rescue nil
  end

  def parse_period(params)
    [parse_date(params[:start_date]), parse_date(params[:end_date])]
  end
  
  def render_bad_request
    render json: { error: "Parâmetros start_date e end_date são obrigatórios e devem estar no formato YYYY-MM-DD." }, status: :bad_request
  end

  def render_not_found(resource_name)
    render json: { error: "#{resource_name} não encontrado." }, status: :not_found
  end
end