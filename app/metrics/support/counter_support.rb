# frozen_string_literal: true
require_relative './metrics_support'

module CounterSupport
  include MetricsSupport

  def fetch_and_format(aggregate = nil)
    # The block on the deep_merge ensures that the final values
    # are added.  Without it, the value is the last value passed in.
    ordered_counters.each_with_object({}) do |values, result|
      prison = values.shift
      result_key = aggregate.blank? ? prison : 'all'
      result[result_key] = result.fetch(result_key, {}).deep_merge(
        order_and_hash_visit_values(values)
      ) { |_key, val1, val2| val1 + val2 }
    end
  end
end
