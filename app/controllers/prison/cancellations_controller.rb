class Prison::CancellationsController < ApplicationController
  include StaffResponseContext

  before_action :authenticate_user
  before_action :check_visit_cancellable
  def create
    if cancellation_response.valid?
      cancellation_response.cancel!
      ga_tracker.send_cancelled_visit_event
      flash[:notice] = t('visit_cancelled', scope: %i[prison flash])
      redirect_to prison_visit_path(memoised_visit)
    else
      flash.now[:alert] = cancellation_response.error_message
      @visit = memoised_visit.decorate
      @message = Message.new
      render :new
    end
  end


private

  def cancellation_response
    @cancellation_response ||= CancellationResponse.new(
      memoised_visit,
      cancellation_params,
      user: current_user
    )
  end

  def cancellation_params
    params.
      require(:cancellation).
      permit(reasons: []).
      merge(nomis_cancelled: true)
  end

  def check_visit_cancellable
    unless memoised_visit.can_cancel?
      flash[:notice] = t('already_cancelled', scope: %i[prison flash])
      redirect_to prison_visit_path(memoised_visit)
    end
  end

  def ga_tracker
    @ga_tracker ||= GATracker.new(current_user, memoised_visit, cookies, request)
  end
end
