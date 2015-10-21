RecurringSlot = Struct.new(
  :begin_hour, :begin_minute, :end_hour, :end_minute
) do
  def self.parse(text_range)
    matches = text_range.match(/\A(\d\d)(\d\d)-(\d\d)(\d\d)\z/)
    new(*matches[1, 4].map { |v| v.to_i(10) })
  end

  def on(date)
    ConcreteSlot.new(
      date.year, date.month, date.day,
      begin_hour, begin_minute, end_hour, end_minute
    )
  end
end
