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
    prisoner_number = params[:prisoner_number]

    requested_visits(estates: accessible_estates,
                     prisoner_number: prisoner_number)
    cancellations(estates: accessible_estates,
                  prisoner_number: prisoner_number)
    processed_visits(estates: accessible_estates,
                     prisoner_number: prisoner_number)
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

  def requested_visits(estates:, prisoner_number: nil)
    @requested_visits ||=
      load_requested_visits(estates, prisoner_number: prisoner_number)
  end

  def cancellations(estates:, prisoner_number: nil)
    @cancellations ||=
      load_visitor_cancellations(estates, prisoner_number: prisoner_number)
  end

  def processed_visits(estates:, prisoner_number: nil)
    estate_query = EstateVisitQuery.new(estates)
    @processed_visits ||= estate_query.processed(
      prisoner_number: prisoner_number,
      limit: NUMBER_VISITS)

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

  def load_visitor_cancellations(estates, prisoner_number: nil)
    visits = Visit.preload(:prisoner, :visitors, :cancellation).
             joins(:cancellation).
             from_estates(estates).
             where(cancellations: { nomis_cancelled: false }).
             order('created_at asc')

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end

  def load_requested_visits(estates, prisoner_number: nil)
    visits = Visit.preload(:prisoner, :visitors).
             with_processing_state(:requested).
             from_estates(estates).
             order('created_at asc')

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end
end
