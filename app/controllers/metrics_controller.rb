class MetricsController < ApplicationController
  before_action :authenticate_user, only: :send_confirmed_bookings

  def index
    @prisons = PrisonsDecorator.decorate(Prison.enabled.includes(:estate))
    @dataset = MetricsPresenter.new(all_time_counts)
    @graphs_presenter = GraphMetricsPresenter.new
  end

  def send_confirmed_bookings
    AdminMailer.confirmed_bookings(current_user.email).deliver_later
    flash[:notice] = 'Check your email in a few minutes'

    redirect_to action: :index
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
