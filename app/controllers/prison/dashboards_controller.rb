class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authorize_prison_request
  before_action :authenticate_user

  def inbox
    requested_visits(estates: current_estates)
    cancellations(estates: current_estates)
  end

  def processed
    processed_visits(estates: current_estates)
  end

  def print_visits
    @visit_date = parse_date(params[:visit_date])

    @data = EstateVisitQuery.new(current_estates).
            visits_to_print_by_slot(@visit_date)

    respond_to do |format|
      format.html
      format.csv do
        render csv: BookedVisitsCsvExporter.new(@data),
               filename: 'booked_visits'
      end
    end
  end

  def search
    query = params[:query]
    requested_visits(estates: accessible_estates, query: query)
    cancellations(estates: accessible_estates, query: query)
    processed_visits(estates: accessible_estates, query: query)
    @search_total = @cancellations.size +
                    @requested_visits.size +
                    @processed_visits.size
  end

private

  def requested_visits(estates:, query: nil)
    @requested_visits ||=
      estate_query(estates).requested(query: query)
  end

  def cancellations(estates:, query: nil)
    @cancellations ||=
      estate_query(estates).cancelled(query: query)
  end

  def processed_visits(estates:, query: nil)
    @processed_visits ||= estate_query(estates).processed(
      query: query,
      limit: NUMBER_VISITS)

    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

  def estate_query(estates)
    @estate_query ||= EstateVisitQuery.new(estates)
  end

  def parse_date(date)
    Date.parse(date) if date.present?
  rescue ArgumentError
    flash[:notice] = t('invalid_date', scope: %i[prison flash])
    nil
  end
end
