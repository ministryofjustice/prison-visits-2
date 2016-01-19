module CounterSupport
  def fetch_and_format(aggregate = nil)
    # The block on the deep_merge ensures that the final values
    # are added.  Without it, the value is the last value passed in.
    all.each_with_object({}) do |visit, result|
      visit = visit.attributes
      prison = visit.delete('prison_name')
      result_key = aggregate.blank? ? prison : 'all'
      result[result_key] = result.fetch(result_key, {}).deep_merge(
        order_and_hash_visit_values(visit)
      ) { |_key, val1, val2| val1 + val2 }
    end
  end

protected

  # Takes the attributes of a visitor counter object, extracts the values,
  # orders them from least specific to most specific and returns a hash of
  # the results.
  #
  # For example, with these inputs:
  # {isoyear: 2016, month: 1, day: 1, state: 'booked', count: 2 }
  #
  # The output would be:
  #
  # 2016 => { 1 => { 1 => { 'booked' => 2 }}}
  def order_and_hash_visit_values(visit)
    visit.values.reverse.inject { |result, value|
      { value => result }
    }
  end
end
