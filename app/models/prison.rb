class Prison < ActiveRecord::Base
  using Calendar

  MissingUuidMapping = Class.new(StandardError)

  has_many :visits

  validates :estate, :name, :nomis_id, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  def self.enabled
    where(enabled: true).order(name: :asc)
  end

  def available_slots(today = Time.zone.today)
    parser = SlotDetailsParser.new(slot_details)
    AvailableSlotEnumerator.new(
      first_bookable_date(today),
      last_bookable_date(today),
      parser.recurring_slots,
      parser.anomalous_slots,
      parser.unbookable_dates
    )
  end

  def first_bookable_date(today = Time.zone.today)
    confirm_by(today) + 1
  end

  def last_bookable_date(today = Time.zone.today)
    today + booking_window
  end

  def confirm_by(today = Time.zone.today)
    ((today + 1)..last_bookable_date(today)).
      select { |d| processing_day?(d) }.
      take(lead_days).
      last
  end

private

  def processing_day?(date)
    return false if date.holiday?
    weekend_processing? || date.weekday?
  end
end
