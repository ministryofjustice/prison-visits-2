class SlotDetailsParser
  def initialize(raw)
    @raw = raw
  end

  def recurring_slots
    @raw.fetch('recurring', {}).map { |day, slots|
      [DayOfWeek.by_name(day), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def anomalous_slots
    @raw.fetch('anomalous', {}).map { |date, slots|
      [Date.parse(date), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def unbookable_dates
    @raw.fetch('unbookable', {}).map { |date| Date.parse(date) }
  end
end
