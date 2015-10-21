class Slot
  def self.parse(text_range)
    matches = text_range.match(/\A(\d\d)(\d\d)-(\d\d)(\d\d)\z/)
    new(*matches[1, 4].map { |v| v.to_i(10) })
  end

  def initialize(start_hour, start_minute, end_hour, end_minute)
    @start_hour = start_hour
    @start_minute = start_minute
    @end_hour = end_hour
    @end_minute = end_minute
  end

  attr_reader :start_hour, :start_minute, :end_hour, :end_minute

  def eql?(other)
    start_hour == other.start_hour &&
      start_minute == other.start_minute &&
      end_hour == other.end_hour &&
      end_minute == other.end_minute
  end

  alias_method :==, :eql?
end
