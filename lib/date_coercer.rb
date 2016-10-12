# Coerces date input into either a Date (if the date is valid)
module DateCoercer
  def self.coerce(value)
    case
    when value.nil?                  then nil
    when value.is_a?(Date)           then value
    when value.respond_to?(:to_date)
      rescue_invalid_date { value.to_date }
    when value.respond_to?(:values_at)
      ymd = value.values_at(:year, :month, :day)
      rescue_invalid_date { Date.new(*ymd.map(&:to_i)) }
    end
  end

private

  def self.rescue_invalid_date
    yield
  rescue ArgumentError => e # e.g. invalid date such as 2010-14-31
    # TODO: remove once it has been in production
    # for a while, this is just for monitoring purpose.
    Raven.capture_exception(e)
    nil
  end
end
