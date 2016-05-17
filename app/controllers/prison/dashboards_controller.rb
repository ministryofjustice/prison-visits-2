class Prison::DashboardsController < ApplicationController
  before_action :authorize_prison_request

  def index
    @estates = Estate.order('name asc').all
  end

  def show
    @estate = Estate.find_by(finder_slug: params[:estate_id])
  end
end
