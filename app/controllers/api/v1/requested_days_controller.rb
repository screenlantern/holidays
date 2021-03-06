class Api::V1::RequestedDaysController < ApplicationController
  before_action :check_admin_user, only: [:approve, :reject]
  before_action :set_vacation_request, except: :index

  def index
    requested_days = load_requested_days

    render json: requested_days, root: :requested_days
  end

  def create
    requested_day = @vacation_request.requested_days.build requested_day_params

    if requested_day.save
      render json: requested_day, status: :ok
    else
      render json: requested_day.errors, status: :unprocessable_entity
    end
  end

  def destroy
    requested_day = @vacation_request.requested_days.find params[:id]
    requested_day.destroy!

    render json: requested_day, status: :ok
  end

  def approve
    requested_day = @vacation_request.requested_days.find params[:id]
    vacation_request_manager = VacationRequestManager.new @vacation_request

    vacation_request_manager.approve_requested_day requested_day

    render json: requested_day, status: :ok
  end

  def reject
    requested_day = @vacation_request.requested_days.find params[:id]
    vacation_request_manager = VacationRequestManager.new @vacation_request

    vacation_request_manager.reject_requested_day requested_day

    render json: requested_day, status: :ok
  end

  private

  def load_requested_days
    return RequestedDay.includes(vacation_request: [:user]).approved unless params[:date].present?

    RequestedDay.includes(vacation_request: [:user]).by_month(Date.parse(params[:date]), 5).approved
  end

  def check_admin_user
    render json: false, status: :forbidden and return unless current_user.admin
  end

  def set_vacation_request
    @vacation_request = VacationRequest.find params[:vacation_request_id]
  end

  def requested_day_params
    if current_user.admin
      params.require(:requested_day).permit(
        :day,
        :status
      )
    else
      params.require(:requested_day).permit(
        :day
      )
    end
  end
end
