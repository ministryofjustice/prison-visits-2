class SlotDetailsParser
  def parse(raw)
    SlotDetails.new(
      parse_recurring_slots(raw),
      parse_anomalous_slots(raw),
      parse_unbookable_dates(raw)
    )
  end

private

  def parse_recurring_slots(raw)
    raw.fetch('recurring', {}).map { |day, slots|
      [DayOfWeek.by_name(day), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def parse_anomalous_slots(raw)
    raw.fetch('anomalous', {}).map { |date, slots|
      [parse_date(date), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def parse_unbookable_dates(raw)
    raw.fetch('unbookable', {}).map { |date| parse_date(date) }
  end

  def parse_date(date)
    # This is necessary because, whilst we initially obtain Date objects from
    # parsing YAML, these are converted to strings when storing them in the
    # JSON field in the database.
    date.is_a?(Date) ? date : Date.parse(date)
  end
end
