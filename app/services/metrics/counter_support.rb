module Metrics
  module CounterSupport
    def run
      all.each_with_object({}) do |visit, result|
        visit = visit.attributes
        prison = visit.delete('prison_name') || 'all'
        if result.key?(prison)
          result[prison] = result[prison].deep_merge(hash_visit_data(visit))
        else
          result[prison] = hash_visit_data(visit)
        end
      end
    end

  protected

    def hash_visit_data(visit)
      visit.values.reverse.inject { |result, value|
        { value => result }
      }
    end
  end
end
