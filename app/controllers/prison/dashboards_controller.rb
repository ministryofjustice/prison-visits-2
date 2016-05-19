class Prison::DashboardsController < ApplicationController
  before_action :authorize_prison_request

  def index
    @estates = Estate.order('name asc').all
  end

  def show
    @estate = Estate.find_by!(finder_slug: params[:estate_id])

    @requested_visits = Visit.includes(:prisoner, :visitors).
                        with_processing_state(:requested).
                        from_estate(@estate).
                        order('created_at asc').
                        to_a
  end
end
