class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authorize_prison_request
  before_action :authenticate_user!

  def inbox
    @requested_visits = Visit.includes(:prisoner, :visitors).
                        with_processing_state(:requested).
                        from_estate(user_estate).
                        order('created_at asc').
                        to_a

    @estate = user_estate
  end

  def processed
    @processed_visits = load_processed_visits(user_estate,
      params[:prisoner_number])

    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

  def print_visits
    @visit_date = if params[:visit_date].present?
                    Date.parse(params[:visit_date])
                  end

    @data = EstateVisitQuery.new(user_estate).
            visits_to_print_by_slot(@visit_date)
  end

private

  def user_estate
    current_user.estate
  end

  def load_processed_visits(estate, prisoner_number)
    visits = Visit.preload(:prisoner, :visitors).
             without_processing_state(:requested).
             from_estate(estate).
             order('visits.updated_at desc').
             limit(NUMBER_VISITS)

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end
end
