require 'date_coercer'

class MaybeDate < Virtus::Attribute
  # This coercion is probably not as comprehensive as
  # Virtus::Attribute::Date, but it is understandable and sufficient for
  # our needs

  def coerce(date)
    coerced_date = DateCoercer.coerce(date)
    coerced_date ||= UncoercedDate.new(date) if date.respond_to?(:values_at)
    coerced_date
  end
end
