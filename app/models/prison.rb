class Prison < ActiveRecord::Base
  using Calendar

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MIN_ADULTS = 1

  has_many :visits, dependent: :destroy
  belongs_to :estate

  validates :estate, :name, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :address, :email_address, :phone_no, :postcode,
    presence: true, if: :enabled?
  validate :validate_unbookable_dates

  delegate :recurring_slots, :anomalous_slots, :unbookable_dates,
    to: :parsed_slot_details
  delegate :finder_slug, to: :estate

  scope :enabled, lambda {
    where(enabled: true).order(name: :asc)
  }

  def available_slots(today = Time.zone.today)
    AvailableSlotEnumerator.new(
      first_bookable_date(today), last_bookable_date(today),
      recurring_slots, anomalous_slots, unbookable_dates
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

  def slot_details=(h)
    super
    @parsed_slot_details = SlotDetailsParser.new.parse(h)
  end

  def name
    attempt_translation(:name, super)
  end

  def address
    attempt_translation(:address, super)
  end

private

  def attempt_translation(key, fallback)
    translations.fetch(I18n.locale.to_s, {}).fetch(key.to_s, fallback)
  end

  def parsed_slot_details
    @parsed_slot_details ||= SlotDetailsParser.new.parse(slot_details)
  end

  def adult?(age)
    age >= adult_age
  end

  def processing_day?(date)
    return false if date.holiday?
    weekend_processing? || date.weekday?
  end

  def validate_unbookable_dates
    if unbookable_dates.uniq.length != unbookable_dates.length
      errors.add :slot_details, :duplicate_unbookable_date
    end
    if (unbookable_dates & anomalous_slots.keys).any?
      errors.add :slot_details, :unbookable_and_anomalous_conflict
    end
  end
end
