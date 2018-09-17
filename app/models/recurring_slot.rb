TimeRange = Struct.new(:begin_hour, :begin_minute, :end_hour, :end_minute)

class RecurringSlot < TimeRange
  ParseError = Class.new(ArgumentError)
  InvalidRange = Class.new(ArgumentError)

  PARSE_PATTERN = /
    \A
    ([01][0-9] | 2[0-3]) ([0-5][0-9]) -
    ([01][0-9] | 2[0-3]) ([0-5][0-9])
    \z
  /x

  def self.parse(text_range)
    matches = text_range.match(PARSE_PATTERN)
    fail ParseError, "Cannot parse '#{text_range}'" unless matches

    new(*matches[1, 4].map { |v| v.to_i(10) })
  end

  def initialize(*)
    super

    unless valid_hours? && valid_minutes? && ends_after_begins?
      fail InvalidRange, 'Invalid range'
    end
  end

  def on(date)
    ConcreteSlot.new(
      date.year, date.month, date.day,
      begin_hour, begin_minute, end_hour, end_minute
    )
  end

private

  def valid_hours?
    [begin_hour, end_hour].all? { |h| (0..23).include?(h) }
  end

  def valid_minutes?
    [begin_minute, end_minute].all? { |m| (0..59).include?(m) }
  end

  def ends_after_begins?
    (end_hour * 60 + end_minute) > (begin_hour * 60 + begin_minute)
  end
end
