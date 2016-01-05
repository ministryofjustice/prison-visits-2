class SlotDetailsParser
  def initialize(raw)
    @recurring_slots = parse_recurring_slots(raw)
    @anomalous_slots = parse_anomalous_slots(raw)
    @unbookable_dates = parse_unbookable_dates(raw)
  end

  attr_reader :recurring_slots, :anomalous_slots, :unbookable_dates

private

  def parse_recurring_slots(raw)
    raw.fetch('recurring', {}).map { |day, slots|
      [DayOfWeek.by_name(day), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def parse_anomalous_slots(raw)
    raw.fetch('anomalous', {}).map { |date, slots|
      [Date.parse(date), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def parse_unbookable_dates(raw)
    raw.fetch('unbookable', {}).map { |date| Date.parse(date) }
  end
end
