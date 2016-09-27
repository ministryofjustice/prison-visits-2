UncoercedDate = Struct.new(:year, :month, :day)

# Coerces date input into either a Date (if the date is valid), or an
# UncoercedDate struct which can be redered back to the view for correction
class MaybeDate < Virtus::Attribute
  # This coercion is probably not as comprehensive as
  # Virtus::Attribute::Date, but it is understandable and sufficient for
  # our needs
  # rubocop:disable Metrics/MethodLength
  def coerce(value)
    return nil if value.nil?
    return value if value.is_a?(Date)

    if value.is_a?(String)
      Date.parse(value)
    elsif value.respond_to?(:values_at)
      ymd = value.values_at(:year, :month, :day).map(&:to_i)
      begin
        Date.new(*ymd)
      rescue ArgumentError # e.g. invalid date such as 2010-14-31
        UncoercedDate.new(*ymd)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
