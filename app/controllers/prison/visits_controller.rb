class Prison::VisitsController < ApplicationController
  helper CalendarHelper
  before_action :authorize_prison_request
  before_action :authenticate_user, only: %i[ show nomis_cancelled ]
  before_action :require_login_during_trial, only: %w[process_visit update]

  def process_visit
    @booking_response = BookingResponse.new(visit: load_visit)

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
      render :process_visit
    end
  end

  def nomis_cancelled
    visit = scoped_visit
    visit.confirm_nomis_cancelled
    flash[:notice] = t('nomis_cancellation_confirmed', scope: [:prison, :flash])
    redirect_to prison_inbox_path
  end

  def deprecated_show
    @visit = unscoped_visit
  end

  def show
    @visit = scoped_visit
    @message = @visit.messages.first
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

  def part_of_trial?
    estate = unscoped_visit.prison.estate
    estate.name.in?(Rails.configuration.dashboard_trial)
  end

  def require_login_during_trial
    authenticate_user if part_of_trial?
  end

  def visit_page(visit)
    if current_user
      prison_inbox_path
    else
      prison_deprecated_visit_path(visit)
    end
  end

  def load_visit
    current_user ? scoped_visit : unscoped_visit
  end

  def scoped_visit
    Visit.joins(prison: :estate).
      where(estates: { id: current_user.estate_id }).
      find(params[:id])
  end

  def unscoped_visit
    Visit.find(params[:id])
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :visitor_banned, :visitor_not_on_list, :selection, :reference_no,
        :closed_visit, :allowance_will_renew, :allowance_renews_on,
        :privileged_allowance_available, :privileged_allowance_expires_on,
        :message_body, unlisted_visitor_ids: [], banned_visitor_ids: []
      ).merge(visit: load_visit, user: current_user)
  end
end
