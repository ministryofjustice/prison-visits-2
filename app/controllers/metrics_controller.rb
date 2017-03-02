class MetricsController < ApplicationController
  before_action :authorize_prison_request

  def index
    @prisons = PrisonsDecorator.decorate(Prison.enabled.includes(:estate))
    @dataset = MetricsPresenter.new(all_time_counts)
    @graphs_presenter = GraphMetricsPresenter.new
  end

  def confirmed_bookings
    exporter = WeeklyMetricsConfirmedCsvExporter.new(weeks: 12)

    respond_to do |format|
      format.csv { render csv: exporter, filename: 'weekly_booking_stats' }
    end
  end

  def summary
    @graphs_presenter = GraphMetricsPresenter.new
    @prison = Prison.find(params[:prison_id])
  end

private

  def all_time_counts
    {
      counts: Counters::CountVisitsByPrisonAndState.fetch_and_format,
      timings: Timings::TimelyAndOverdue.fetch_and_format
    }
  end
end
