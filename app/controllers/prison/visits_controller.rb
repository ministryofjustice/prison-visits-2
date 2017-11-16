class Prison::VisitsController < ApplicationController
  include StaffResponseContext

  helper_method :book_to_nomis_config

  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :visit_is_processable, only: :update
  before_action :set_visit_processing_time_cookie, only: :show
  after_action  :track_visit_process, only: :update

  def update
    @booking_response = booking_responder.respond!

    booking_response_flash(@booking_response)

    if @booking_response.success? || @booking_response.already_processed?
      redirect_to prison_inbox_path
    else
      # Always decorate object last once they've been mutated
      @message = message
      @visit = decorate_visit(memoised_visit)
      render :show
    end
  end

  def nomis_cancelled
    memoised_visit.confirm_nomis_cancelled
    flash[:notice] = t('nomis_cancellation_confirmed', scope: %i[prison flash])
    redirect_to prison_inbox_path
  end

  def show
    visit = Visit.
             includes(
               :visitors,
               messages: :user,
               visit_state_changes: :processed_by).
             find(memoised_visit.id)
    @visit = decorate_visit(visit)
    @message = Message.new
  end

private

  def booking_response_flash(booking_response)
    if booking_response.success?
      flash[:notice] = t('process_thank_you', scope: [:prison, :flash])
    else
      flash[:alert] = t("#{booking_response.message}_html", scope: [:prison, :flash])
    end
  end

  def visit_is_processable
    unless memoised_visit.processable?
      flash[:notice] = t('already_processed_html', scope: %i[prison flash])
      redirect_to prison_inbox_path
    end
  end

  def track_visit_process
    if @booking_response.success?
      ga_tracker.send_processing_timing
      ga_tracker.send_unexpected_rejection_event
    end
  end

  def set_visit_processing_time_cookie
    return unless memoised_visit.processable?
    ga_tracker.set_visit_processing_time_cookie
  end

  def ga_tracker
    @tracker ||= GATracker.new(current_user, memoised_visit, cookies, request)
  end
end
