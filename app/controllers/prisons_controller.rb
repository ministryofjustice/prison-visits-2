class PrisonsController < ApplicationController
  def show
    @prison = Prison.find(params[:id])
    @days = DayDecorator.decorate_collection(%w[mon tue wed thu fri sat sun])
  end
end