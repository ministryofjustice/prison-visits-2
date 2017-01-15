class Metrics::ProcessingTimesController < ApplicationController
  def index
    @metrics_presenter = GraphMetricsPresenter.new
    @prisons           = PrisonsDecorator.decorate(Prison.enabled.includes(:estate))
  end

  def show
    @metrics_presenter = GraphMetricsPresenter.new
    @prison            = Prison.find(params[:id])
  end
end
