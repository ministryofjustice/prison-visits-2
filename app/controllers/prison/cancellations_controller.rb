class Prison::CancellationsController < ApplicationController
  include StaffResponseContext

  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :check_visit_cancellable

  def create
    if cancellation_response.valid?
      cancellation_response.cancel!
      flash[:notice] = t('visit_cancelled', scope: %i[prison flash])
      redirect_to prison_visit_path(memoised_visit)
    else
      flash.now[:alert] = cancellation_response.error_message
      @visit = decorate_visit(memoised_visit)
      @message = Message.new
      render :new
    end
  end

private

  def cancellation_response
    @_cancellation_response ||= CancellationResponse.new(
      memoised_visit,
      cancellation_params,
      user: current_user,
      persist_to_nomis: params[:cancel_to_nomis_optout]
    )
  end

  def cancellation_params
    params.require(:cancellation).permit(:nomis_cancelled, reasons: [])
  end

  def check_visit_cancellable
    unless memoised_visit.can_cancel?
      flash[:notice] = t('already_cancelled', scope: %i[prison flash])
      redirect_to prison_visit_path(memoised_visit)
    end
  end
end
