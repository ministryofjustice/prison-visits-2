ConcreteSlot = Struct.new(
  :year, :month, :day, :begin_hour, :begin_minute, :end_hour, :end_minute
) do
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

  def iso8601
    '%04d-%02d-%02dT%02d:%02d/%02d:%02d' % [
      year, month, day, begin_hour, begin_minute, end_hour, end_minute
    ]
  end
end
