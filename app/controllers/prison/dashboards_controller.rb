class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authorize_prison_request
  before_action :authenticate_user
  before_action :set_inbox_navigation_count

  def inbox
    @requested_visits = load_requested_visits(user_estate,
      params[:prisoner_number])

    @cancellations = load_visitor_cancellations(user_estate)

    @estate = user_estate
  end

  def processed
    estate_query = EstateVisitQuery.new(user_estate)
    @processed_visits = estate_query.
                        processed(prisoner_number: params[:prisoner_number],
                                  limit: NUMBER_VISITS)

    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

  def print_visits
    @visit_date = parse_date(params[:visit_date])

    @data = EstateVisitQuery.new(user_estate).
            visits_to_print_by_slot(@visit_date)

    respond_to do |format|
      format.html
      format.csv do
        render csv: BookedVisitsCsvExporter.new(@data),
               filename: 'booked_visits'
      end
    end
  end

private

  def parse_date(date)
    Date.parse(date) if date
  end

  def user_estate
    current_user.estate
  end

  def load_visitor_cancellations(estate)
    Visit.
      preload(:prisoner, :visitors).
      joins(:cancellation).
      from_estate(estate).
      where(cancellations: { nomis_cancelled: false }).
      order('created_at asc').
      to_a
  end

  def load_requested_visits(estate, prisoner_number)
    visits = Visit.preload(:prisoner, :visitors).
             with_processing_state(:requested).
             from_estate(estate).
             order('created_at asc')

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end
end
