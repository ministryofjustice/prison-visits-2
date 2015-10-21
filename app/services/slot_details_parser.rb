class SlotDetailsParser
  def initialize(raw)
    @raw = raw
  end

  def regular_slots
    @raw.fetch('regular', {}).map { |day, slots_as_text|
      [DayOfWeek.by_name(day), slots_as_text.map { |t| RecurringSlot.parse(t) }]
    }.to_h
  end

  def unbookable_dates
    @raw.fetch('unbookable', {}).map { |text| Date.parse(text) }
  end
end
