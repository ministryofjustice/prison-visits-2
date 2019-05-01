ConcreteSlot = Struct.new(
  :year, :month, :day, :begin_hour, :begin_minute, :end_hour, :end_minute
) do
  include Comparable

  def self.parse(str)
    m = str.match(%r{
      \A (\d\d\d\d) - (\d\d) - (\d\d) T (\d\d) : (\d\d) / (\d\d) : (\d\d) \z
    }x)
    if m
      new(*m[1, 7].map { |s| s.to_i(10) })
    else
      fail ArgumentError, %{cannot parse "#{str}"}
    end
  end

  def self.parse_times(begin_at, end_at)
    new(begin_at.year, begin_at.mon, begin_at.day, begin_at.hour, begin_at.min,
        end_at.hour, end_at.min)
  end

  def iso8601
    '%04d-%02d-%02dT%02d:%02d/%02d:%02d' % [
      year, month, day, begin_hour, begin_minute, end_hour, end_minute
    ]
  end

  alias_method :to_s, :iso8601

  def to_date
    Date.new(year, month, day)
  end

  def on?(date)
    to_date == date
  end

  # We are explicitly parsing these as UTC, but this Rubocop cop isn't clever
  # We use UTC because we don't actually care about time zone offsets: booking
  # times are always given in terms of wall time, and we only use Time to give
  # us a convenient way to perform maths and to format dates and times for
  # output.
  #
  def begin_at
    Time.new(year, month, day, begin_hour, begin_minute, 0, '+00:00')
  end

  def end_at
    Time.new(year, month, day, end_hour, end_minute, 0, '+00:00')
  end

  def duration
    (end_at - begin_at).to_i
  end

  def <=>(other)
    to_s <=> other.to_s
  end

  def overlaps?(other)
    end_at > other.begin_at
  end
end
