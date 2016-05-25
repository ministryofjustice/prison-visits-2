class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

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

  def processed
    @estate = Estate.find_by!(finder_slug: params[:estate_id])

    @processed_visits = load_processed_visits(@estate, params[:prisoner_number])

    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

private

  def load_processed_visits(estate, prisoner_number)
    visits = Visit.preload(:prisoner, :visitors).
             without_processing_state(:requested).
             from_estate(estate).
             order('visits.updated_at desc').
             limit(NUMBER_VISITS)

    if prisoner_number
      visits = visits.joins(:prisoner).
               where('prisoners.number ILIKE ?', prisoner_number.strip)
    end

    visits.to_a
  end
end
