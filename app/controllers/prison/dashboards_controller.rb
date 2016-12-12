class Prison::DashboardsController < ApplicationController
  NUMBER_VISITS = 101

  before_action :authorize_prison_request
  before_action :authenticate_user

  def inbox
    requested_visits
    cancellations

    @estates = current_estates
  end

  def processed
    processed_visits
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
    requested_visits
    cancellations
    processed_visits

    @estates = current_estates
  end

  def switch_estates
    estates = Estate.where(id: params[:estates_id])

    if sso_identity.accessible_estates?(estates)
      @_current_estates         = nil
      session[:current_estates] = estates.map(&:id)
    else
      # This should never happen
      flash[:notice] = "You don't access to these estates"
    end

    redirect_to :back
  end

private

  def requested_visits
    @requested_visits ||= load_requested_visits(current_estates)
  end

  def cancellations
    @cancellations ||= load_visitor_cancellations(current_estates)
  end

  def processed_visits
    estate_query = EstateVisitQuery.new(current_estates)
    @processed_visits ||= estate_query.processed(limit: NUMBER_VISITS)

    if @processed_visits.size == NUMBER_VISITS
      @processed_visits.pop # Show only 100 most recent visits
      @all_visits_shown = false
    else
      @all_visits_shown = true
    end
  end

  def parse_date(date)
    Date.parse(date) unless date.blank?
  rescue ArgumentError
    flash[:notice] = t('invalid_date', scope: [:prison, :flash])
    nil
  end

  def load_visitor_cancellations(estates)
    visits = Visit.preload(:prisoner, :visitors, :cancellation).
             joins(:cancellation).
             from_estates(estates).
             where(cancellations: { nomis_cancelled: false }).
             order('created_at asc')

    visits.to_a
  end

  def load_requested_visits(estates)
    visits = Visit.preload(:prisoner, :visitors).
             with_processing_state(:requested).
             from_estates(estates).
             order('created_at asc')

    visits.to_a
  end
end
