class Prison::VisitsController < ApplicationController
  include StaffResponseContext
  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :cancellation_reason_set, only: :cancel
  before_action :visit_is_processable, only: :update

  def update
    booking_response = booking_responder.respond!
    if booking_response.success?
      flash[:notice] = t('process_thank_you', scope: %i[prison flash])
      redirect_to prison_inbox_path
    else
      # Always decorate object last once they've been mutated
      @message = message
      flash[:alert] = t('process_required', scope: %i[prison flash])
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

  def cancel
    if cancellation_response.can_cancel?
      cancellation_response.cancel!
      flash[:notice] = t('visit_cancelled', scope: %i[prison flash])
    else
      flash[:notice] = t('already_cancelled', scope: %i[prison flash])
    end

    redirect_to action: :show
  end

private

  def visit_is_processable
    unless memoised_visit.processable?
      flash[:notice] = t('already_processed', scope: %i[prison flash])
      redirect_to prison_inbox_path
    end
  end

  def cancellation_response
    @_cancellation_response ||=
      CancellationResponse.new(
        visit: memoised_visit,
        user: current_user,
        reason: params[:cancellation_reason])
  end

  def cancellation_reason_set
    unless params[:cancellation_reason]
      flash[:notice] = t('no_cancellation_reason', scope: %i[prison flash])
      redirect_to action: :show
    end
  end
end
