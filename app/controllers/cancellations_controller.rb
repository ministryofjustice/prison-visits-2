class CancellationsController < ApplicationController
  def create
    visit = Visit.find(params[:id])
    visit.cancel! if confirmed?
    redirect_to visit_path(visit)
  end

private

  def confirmed?
    params[:confirmed].present?
  end
end
