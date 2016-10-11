class Prison::VisitsController < ApplicationController
  include BookingResponseContext
  before_action :authorize_prison_request
  before_action :authenticate_user, only: %i[ show nomis_cancelled ]
  before_action :require_login_during_trial, only: %w[process_visit update]

  def process_visit
    visit = load_visit.find(params[:id])
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
    visit = scoped_visit.find(params[:id])
    visit.confirm_nomis_cancelled
    flash[:notice] = t('nomis_cancellation_confirmed', scope: [:prison, :flash])
    redirect_to prison_inbox_path
  end

  def deprecated_show
    @visit = unscoped_visit.find(params[:id])
  end

  def show
    @visit = scoped_visit.
             includes(
               :visitors,
               messages: :user,
               visit_state_changes: :processed_by).
             find(params[:id])
    @message = Message.new
  end

  def cancel
    @visit = load_visit.find(params[:id])
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
      prison_deprecated_visit_path(visit)
    end
  end

  def load_visit
    current_user ? scoped_visit : unscoped_visit
  end

  def scoped_visit
    Visit.joins(prison: :estate).
      where(estates: { id: current_estate })
  end

  def unscoped_visit
    Visit
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :visitor_banned, :visitor_not_on_list, :selection, :reference_no,
        :allowance_will_renew, :privileged_allowance_available, :message_body,
        :closed_visit,
        allowance_renews_on: [:day, :month, :year],
        privileged_allowance_expires_on: [:day, :month, :year],
        unlisted_visitor_ids: [], banned_visitor_ids: []
      ).merge(visit: load_visit.find(params[:id]), user: current_user)
  end
end
