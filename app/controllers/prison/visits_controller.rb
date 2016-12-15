class Prison::VisitsController < ApplicationController
  include BookingResponseContext
  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :cancellation_reason_set, only: :cancel
  before_action :visit_is_processable, only: [:process_visit, :update]

  def process_visit
    @visit            = load_visit.decorate
    @booking_response = BookingResponse.new(visit: @visit)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def update
    @visit = load_visit
    @visit.assign_attributes(visit_params)
    @booking_response = BookingResponse.new(visit: @visit, user: current_user)

    if @booking_response.valid?
      BookingResponder.new(@booking_response, message).respond!
      flash[:notice] = t('process_thank_you', scope: [:prison, :flash])
      redirect_to prison_inbox_path
    else
      # Always decorate object last once they've been mutated
      @visit = @visit.decorate
      flash[:alert] = t('process_required', scope: [:prison, :flash])
      render :process_visit
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  def nomis_cancelled
    load_visit.confirm_nomis_cancelled
    flash[:notice] = t('nomis_cancellation_confirmed', scope: [:prison, :flash])
    redirect_to prison_inbox_path
  end

  def show
    @visit = Visit.
             includes(
               :visitors,
               messages: :user,
               visit_state_changes: :processed_by).
             find(load_visit.id).decorate
    @message = Message.new
  end

  def cancel
    if cancellation_response.can_cancel?
      cancellation_response.cancel!
      flash[:notice] = t('visit_cancelled', scope: [:prison, :flash])
    else
      flash[:notice] = t('already_cancelled', scope: [:prison, :flash])
    end

    redirect_to action: :show
  end

private

  def visit_is_processable
    unless load_visit.processable?
      flash[:notice] = t('already_processed', scope: [:prison, :flash])
      redirect_to prison_inbox_path
    end
  end

  def cancellation_response
    @_cancellation_response ||=
      CancellationResponse.new(
        visit: load_visit,
        user: current_user,
        reason: params[:cancellation_reason])
  end

  def cancellation_reason_set
    unless params[:cancellation_reason]
      flash[:notice] = t('no_cancellation_reason', scope: [:prison, :flash])
      redirect_to action: :show
    end
  end
end
