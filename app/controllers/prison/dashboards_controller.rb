class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authorize_prison_request
  before_action :authenticate_user

  def inbox
    requested_visits
    cancellations

    @estate = current_estate
  end

  def processed
    processed_visits
  end

  def print_visits
    @visit_date = parse_date(params[:visit_date])

    @data = EstateVisitQuery.new(current_estate).
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
    requested_visits
    cancellations
    processed_visits

    @estate = current_estate
  end

private

  def requested_visits
    @requested_visits ||= load_requested_visits(current_estate,
      prisoner_number)
  end

  def cancellations
    @cancellations ||= load_visitor_cancellations(current_estate,
      prisoner_number)
  end

  def processed_visits
    estate_query = EstateVisitQuery.new(current_estate)
    @processed_visits ||= estate_query.
                          processed(prisoner_number: params[:prisoner_number],
                                    limit: NUMBER_VISITS)
    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

  def prisoner_number
    params[:prisoner_number]
  end

  def parse_date(date)
    Date.parse(date) unless date.blank?
  rescue ArgumentError
    flash[:notice] = t('invalid_date', scope: [:prison, :flash])
    nil
  end

  def load_visitor_cancellations(estate, prisoner_number)
    visits = Visit.preload(:prisoner, :visitors).
             joins(:cancellation).
             from_estate(estate).
             where(cancellations: { nomis_cancelled: false }).
             order('created_at asc')

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end
    visits.to_a
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
