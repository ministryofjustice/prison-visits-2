class CancellationsController < ApplicationController
  def create
    visit = Visit.find(params[:id])
    if confirmed?
      visit.cancel!
      PrisonMailer.canceled(visit).deliver_later
    end
    redirect_to visit_path(visit)
  end

private

  def confirmed?
    params[:confirmed].present?
  end
end
