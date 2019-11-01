class SlotDetailsParser
  def parse(raw)
    SlotDetails.new(
      parse_anomalous_slots(raw)
    )
  end

private

  def parse_anomalous_slots(raw)
    raw.fetch('anomalous', {}).map { |date, slots|
      [parse_date(date), slots.map { |s| RecurringSlot.parse(s) }]
    }.to_h
  end

  def parse_date(date)
    # This is necessary because, whilst we initially obtain Date objects from
    # parsing YAML, these are converted to strings when storing them in the
    # JSON field in the database.
    date.is_a?(Date) ? date : Date.parse(date)
  end
end
