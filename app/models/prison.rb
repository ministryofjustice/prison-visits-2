class Prison < ActiveRecord::Base
  using Calendar

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MIN_ADULTS = 1

  has_many :visits, dependent: :destroy

  validates :estate, :name, :nomis_id, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :email_address, presence: true, if: :enabled?

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

  def bookable_date?(requested_date = Time.zone.today)
    available_slots.any? { |slot| slot.on?(requested_date) }
  end

  def confirm_by(today = Time.zone.today)
    ((today + 1)..last_bookable_date(today)).
      select { |d| processing_day?(d) }.
      take(lead_days).
      last
  end

  def validate_visitor_ages_on(target, field, ages)
    adults, _children = ages.partition { |a| adult?(a) }.map(&:length)
    if adults > MAX_ADULTS
      target.errors.add field, :too_many_adults, max: MAX_ADULTS, age: adult_age
    elsif adults < MIN_ADULTS
      target.errors.add field, :too_few_adults, min: MIN_ADULTS, age: adult_age
    end
  end

private

  def adult?(age)
    age >= adult_age
  end

  def processing_day?(date)
    return false if date.holiday?
    weekend_processing? || date.weekday?
  end
end
