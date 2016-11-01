# frozen_string_literal: true
class Prison::VisitsController < ApplicationController
  include BookingResponseContext
  before_action :authorize_prison_request
  before_action :require_login_during_trial,
    only: %w[show nomis_cancelled process_visit update]
  before_action :cancellation_reason_set, only: :cancel

  def process_visit
    visit = load_visit
    @booking_response = BookingResponse.new(visit: visit)
    @nomis_checker = StaffNomisChecker.new(visit)

    unless @booking_response.processable?
      flash[:notice] = t('already_processed', scope: [:prison, :flash])
      redirect_to visit_page(@booking_response.visit)
    end
  end

  def update
    @booking_response = BookingResponse.new(booking_response_params)
    if @booking_response.valid?
      @visit = @booking_response.visit
      BookingResponder.new(@booking_response).respond!
      flash[:notice] = t('process_thank_you', scope: [:prison, :flash])
      redirect_to visit_page(@visit)
    else
      @nomis_checker = StaffNomisChecker.new(@booking_response.visit)
      render :process_visit
    end
  end

  def nomis_cancelled
    visit = load_visit
    visit.confirm_nomis_cancelled
    flash[:notice] = t('nomis_cancellation_confirmed', scope: [:prison, :flash])
    redirect_to prison_inbox_path
  end

  def show
    @visit = Visit.
             includes(
               :visitors,
               messages: :user,
               visit_state_changes: :processed_by
             ).
             find(load_visit.id)
    @nomis_checker = StaffNomisChecker.new(@visit)
    @message = Message.new
  end

  def cancel
    @visit = load_visit

    if @visit.can_cancel?
      @visit.staff_cancellation!(params[:cancellation_reason])
      flash[:notice] = t('visit_cancelled', scope: [:prison, :flash])
    else
      flash[:notice] = t('already_cancelled', scope: [:prison, :flash])
    end

    redirect_to visit_page(@visit)
  end

private

  def cancellation_reason_set
    unless params[:cancellation_reason]
      flash[:notice] = t('no_cancellation_reason', scope: [:prison, :flash])
      redirect_to action: :show
    end
  end

  def part_of_trial?
    estate_name = Estate.
                  joins(prisons: :visits).
                  where(visits: { id: params[:id] }).
                  pluck('estates.name').
                  first
    estate_name.in?(Rails.configuration.dashboard_trial)
  end

  def require_login_during_trial
    authenticate_user if part_of_trial?
  end

  def visit_page(visit)
    if current_user
      prison_inbox_path
    else
      prison_visit_path(visit)
    end
  end
end
