class MetricsController < ApplicationController
  def index
    @prisons = PrisonsDecorator.decorate(Prison.enabled.includes(:estate))
    @dataset = MetricsPresenter.new(**all_time_counts)
    @graphs_presenter = GraphMetricsPresenter.new
  end

  def summary
    @graphs_presenter = GraphMetricsPresenter.new
    @prison = Prison.find(params[:prison_id])
  end

  def digital_takeup; end

private

  def all_time_counts
    {
      counts: Counters::CountVisitsByPrisonAndState.fetch_and_format,
      timings: Timings::TimelyAndOverdue.fetch_and_format
    }
  end
end
