class CancellationsController < ApplicationController
  def create
    visit = Visit.find(params[:id])
    if cancellation_confirmed? && visit.can_cancel?
      visit.cancel!
    end
    redirect_to visit_path(visit)
  end

private

  def cancellation_confirmed?
    params[:confirmed].present?
  end
end
