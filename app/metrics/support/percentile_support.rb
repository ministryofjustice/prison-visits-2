require_relative './metrics_support'

module PercentileSupport
  include MetricsSupport

  CENTILES = [95, 50].freeze

  def fetch_and_format(aggregate = nil)
    ordered_counters.each_with_object({}) do |values, result|
      prison = values.shift
      values << hash_centiles(values.pop)
      result_key = aggregate.blank? ? prison : 'all'
      result[result_key] = result.fetch(result_key, {}).deep_merge(
        order_and_hash_visit_values(values)
      )
    end
  end

private

  def hash_centiles(result)
    Hash[CENTILES.zip(result)]
  end
end
