# rubocop:disable Layout/AccessModifierIndentation
module MetricsSupport
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
  def order_and_hash_visit_values(values)
    values.reverse.inject { |result, value|
      { value => result }
    }
  end
end
# rubocop:enable Layout/AccessModifierIndentation
