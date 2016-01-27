require_relative './metrics_support'

module PercentileSupport
  include MetricsSupport

  CENTILES = [99, 95, 90, 75, 50, 25]

  def centiles
    CENTILES
  end

  def fetch_and_format(aggregate = nil)
    all.each_with_object({}) do |distrib, result|
      metrics = distrib.attributes
      metrics['percentiles'] = hash_centiles(metrics.delete('percentiles'))
      prison = metrics.delete('prison_name')
      result_key = aggregate.blank? ? prison : 'all'
      result[result_key] = result.fetch(result_key, {}).deep_merge(
        order_and_hash_visit_values(metrics)
      )
    end
  end

private

  def hash_centiles(result)
    Hash[centiles.zip(result)]
  end
end
