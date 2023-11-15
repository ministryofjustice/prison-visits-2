class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authenticate_user

  def inbox
    requested_visits(estates: current_estates)
    cancellations(estates: current_estates)
  end

  def processed
    processed_visits(estates: current_estates)
  end

  def search
    query = params[:query]
    requested_visits(estates: accessible_estates, query:)
    cancellations(estates: accessible_estates, query:)
    processed_visits(estates: accessible_estates, query:)
    @search_total = @cancellations.size +
                    @requested_visits.size +
                    @processed_visits.size
  end

private

  def requested_visits(estates:, query: nil)
    @requested_visits ||=
      estate_query(estates).requested(query:)
  end

  def cancellations(estates:, query: nil)
    @cancellations ||=
      estate_query(estates).cancelled(query:)
  end

  def processed_visits(estates:, query: nil)
    @processed_visits ||= estate_query(estates).processed(
      query:,
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
end
