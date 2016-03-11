class MetricsController < ApplicationController
  before_action :authorize_prison_request

  def index
    counts = Counters::CountVisitsByPrisonAndState.fetch_and_format
    overdue_counts = Overdue::CountOverdueVisitsByPrison.ordered_counters
    percentiles = Percentiles::DistributionByPrison.ordered_counters.to_h

    @dataset = MetricsPresenter.new(counts, overdue_counts, percentiles)
  end

private

  def authorize_prison_request
    unless Rails.configuration.prison_ip_matcher.include?(request.remote_ip)
      Rails.logger.info "Unauthorized request from #{request.remote_ip}"
      fail ActionController::RoutingError, 'Not Found'
    end
  end
end
