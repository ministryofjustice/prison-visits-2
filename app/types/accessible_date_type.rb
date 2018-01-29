class AccessibleDateType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(Date)
      AccessibleDate.new(year: value.year, month: value.month, day: value.day)
    elsif value.is_a?(String)
      year, month, day = value.split('-').map(&:to_i)
      AccessibleDate.new(year: year, month: month, day: day)
    elsif value.respond_to?(:values_at)
      cast_with_values_at(value)
    end
  end

private

  def cast_with_values_at(value)
    hash = Hash[[:year, :month, :day].
                zip(value.with_indifferent_access.values_at(:year, :month, :day))]
    return nil if hash.values == [0, 0, 0]

    AccessibleDate.new(hash)
  end
end
