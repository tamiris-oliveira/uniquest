class ReportsController < ApplicationController
  before_action :authenticate_request!

  # GET /reports?start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
  def index
    start_date, end_date = parse_period(params)
    return render json: { error: "Parâmetros start_date e end_date são obrigatórios." }, status: :bad_request unless start_date && end_date

    render json: performance_summary_data(@current_user.id, start_date, end_date)
  end

  def show
    render json: { error: "Relatório salvo não existe. Use endpoints dinâmicos." }, status: :not_found
  end

  def performance_summary
    start_date, end_date = parse_period(params)
    return render json: { error: "Parâmetros start_date e end_date são obrigatórios." }, status: :bad_request unless start_date && end_date

    render json: performance_summary_data(@current_user.id, start_date, end_date)
  end

  def performance_by_subject
    start_date, end_date = parse_period(params)
    return render json: { error: "Parâmetros start_date e end_date são obrigatórios." }, status: :bad_request unless start_date && end_date

    render json: performance_by_subject_data(@current_user.id, start_date, end_date)
  end

  def performance_by_period
    performance_summary
  end

  def group_performance
    return render json: { error: "Acesso não autorizado." }, status: :forbidden unless @current_user.role == 1

    group_id = params[:group_id]
    start_date, end_date = parse_period(params)
    return render json: { error: "group_id, start_date e end_date são obrigatórios." }, status: :bad_request unless group_id && start_date && end_date

    group = Group.find_by(id: group_id)
    return render json: { error: "Grupo não encontrado." }, status: :not_found unless group

    user_ids = group.users.pluck(:id)
    render json: group_performance_data(user_ids, group, start_date, end_date)
  end

  private

  def parse_date(date_str)
    Date.parse(date_str) rescue nil
  end

  def parse_period(params)
    [parse_date(params[:start_date]), parse_date(params[:end_date])]
  end

  # --- MÉTODOS DE DADOS ---

  def performance_summary_data(user_id, start_date, end_date)
    attempts = Attempt.where(user_id: user_id)
                      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                      .includes(answers: [:question, :corrections])

    total_correct = 0
    total_incorrect = 0
    total_manual = 0.0
    evolution = []

    attempts.sort_by(&:created_at).each do |attempt|
      correct = 0
      incorrect = 0
      manual = 0.0

      attempt.answers.each do |ans|
        if ans.question.question_type == "Objetiva"
          ans.correct ? correct += 1 : incorrect += 1
        else
          grade = ans.corrections.last&.grade.to_f
          manual += grade if grade
        end
      end

      total_correct += correct
      total_incorrect += incorrect
      total_manual += manual

      evolution << {
        date: attempt.created_at.to_date,
        correct: correct,
        incorrect: incorrect,
        manual_grade: manual.round(2),
        total_grade: (correct + manual).round(2)
      }
    end

    {
      total_attempts: attempts.size,
      total_correct_answers: total_correct,
      total_incorrect_answers: total_incorrect,
      total_manual_grade: total_manual.round(2),
      total_grade: (total_correct + total_manual).round(2),
      evolution: evolution
    }
  end

  def performance_by_subject_data(user_id, start_date, end_date)
    answers = Answer.joins(:question, :attempt)
                    .where(attempts: { user_id: user_id, created_at: start_date.beginning_of_day..end_date.end_of_day })
                    .includes(:corrections)

    grouped = answers.group_by { |a| a.question.subject&.name || "Indefinido" }

    grouped.map do |subject, answers_list|
      correct = 0
      incorrect = 0
      manual_total = 0.0
      manual_count = 0

      answers_list.each do |ans|
        if ans.question.question_type == "Objetiva"
          ans.correct ? correct += 1 : incorrect += 1
        else
          grade = ans.corrections.last&.grade
          if grade
            manual_total += grade.to_f
            manual_count += 1
          end
        end
      end

      {
        subject_name: subject,
        correct_answers: correct,
        incorrect_answers: incorrect,
        manual_total_grade: manual_total.round(2),
        manual_average: manual_count > 0 ? (manual_total / manual_count).round(2) : 0.0,
        total_questions: answers_list.count
      }
    end
  end

  def group_performance_data(user_ids, group, start_date, end_date)
    attempts = Attempt.where(user_id: user_ids)
                      .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
                      .includes(:user, answers: [:question, :corrections])

    user_stats = Hash.new { |h, k| h[k] = { name: "", total: 0.0, attempts: 0 } }
    question_stats = Hash.new { |h, k| h[k] = { statement: "", correct: 0, incorrect: 0 } }

    total_correct = 0
    total_incorrect = 0
    total_manual = 0.0

    attempts.each do |attempt|
      user = attempt.user
      correct = 0
      manual = 0.0

      attempt.answers.each do |ans|
        q_id = ans.question.id
        question_stats[q_id][:statement] ||= ans.question.statement

        if ans.question.question_type == "Objetiva"
          if ans.correct
            total_correct += 1
            question_stats[q_id][:correct] += 1
          else
            total_incorrect += 1
            question_stats[q_id][:incorrect] += 1
          end
        else
          grade = ans.corrections.last&.grade
          if grade
            total_manual += grade.to_f
            manual += grade.to_f
          end
        end
      end

      user_stats[user.id][:name] = user.name
      user_stats[user.id][:total] += (correct + manual)
      user_stats[user.id][:attempts] += 1
    end

    ranking = user_stats.map do |user_id, data|
      {
        user_id: user_id,
        name: data[:name],
        avg_grade: (data[:attempts] > 0 ? data[:total] / data[:attempts] : 0).round(2)
      }
    end.sort_by { |u| -u[:avg_grade] }

    most_difficult = question_stats.map do |q_id, data|
      total = data[:correct] + data[:incorrect]
      {
        question_id: q_id,
        statement: data[:statement],
        correct: data[:correct],
        incorrect: data[:incorrect],
        total: total,
        error_rate: total > 0 ? (data[:incorrect].to_f / total * 100).round(1) : 0
      }
    end.sort_by { |q| -q[:error_rate] }.first(5)

    {
      group_id: group.id,
      group_name: group.name,
      students_count: user_ids.size,
      total_attempts: attempts.size,
      total_correct_answers: total_correct,
      total_incorrect_answers: total_incorrect,
      total_manual_grade: total_manual.round(2),
      total_grade: (total_correct + total_manual).round(2),
      ranking: ranking,
      most_difficult_questions: most_difficult
    }
  end
end
