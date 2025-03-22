class ReportsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_report, only: [ :show, :update, :destroy ]

  def index
    @reports = @current_user.reports
    render json: @reports
  end

  def show
    render json: @report
  end

  def create
    @report = @current_user.reports.build(report_params)

    if @report.save
      render json: @report, status: :created, location: report_url(@report)
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  def update
    if @report.update(report_params)
      render json: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @report.destroy
    head :no_content
  end

  private

  def set_report
    @report = @current_user.reports.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:simulation_id, :correct_answers, :incorrect_answers, :total_grade, :generation_date)
  end
end
