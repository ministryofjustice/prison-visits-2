class VisitsController < ApplicationController
  def show
    @visit = Visit.find(params[:id])
  end
end
