class Prison < ApplicationRecord
  MAX_VISITORS = 6
  MAX_ADULTS = 3
  LEAD_VISITOR_MIN_AGE = 18

  has_many :visits, dependent: :destroy
  belongs_to :estate

  validates :estate, :name, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }
  validates :address, :email_address, :phone_no, :postcode,
            presence: true, if: :enabled?
  validate :validate_unbookable_dates

  validates :booking_window, numericality: {
    less_than_or_equal_to: PrisonSeeder::SeedEntry::DEFAULT_BOOKING_WINDOW
  }

  delegate :anomalous_slots,
           to: :parsed_slot_details
  delegate :finder_slug, :nomis_id, to: :estate

  scope :enabled, (lambda {
    where(enabled: true).order(name: :asc)
  })

  has_many :unbookable_dates, dependent: :destroy
  has_many :slot_days, dependent: :destroy

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Style/MultilineBlockChain
  def recurring_slots(today = Time.zone.today)
    # pick out 'active' item for each slot_day (which might be nil)
    # and then convert to a hash of DayOfWeek -> RecurringSlot array
    # so that it matches what it used to do before the data was stored
    # as a JSON blob
    slot_days.group_by(&:day).values.map { |days_array|
      days_array.
        sort_by(&:start_date).
        detect { |sd| today >= sd.start_date }
    }.compact.map { |day|
      [
        DayOfWeek.by_name(day.day),
        day.slot_times.map do |t|
          RecurringSlot.new(t.start_hour, t.start_minute, t.end_hour, t.end_minute)
        end
      ]
    }.to_h
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Style/MultilineBlockChain

  def available_slots(today = Time.zone.today)
    AvailableSlotEnumerator.new(
      first_bookable_date(today), last_bookable_date(today),
      recurring_slots(today), anomalous_slots, unbookable_dates.map(&:date)
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

  def validate_visitor_ages_on(target, field, ages)
    # This validation does not apply if there are no visitors
    return if ages.empty?

    # The person requesting the visit (the lead visitor) must be over 18, and
    # corresponds to the first visitor entered.
    # Note that this is not related to the 'adult' age which varies by prison.
    if ages.first < LEAD_VISITOR_MIN_AGE
      target.errors.add(field, :lead_visitor_age, min: LEAD_VISITOR_MIN_AGE)
    end

    adults, _children = ages.partition { |a| adult?(a) }.map(&:length)
    if adults > MAX_ADULTS
      target.errors.add field, :too_many_adults, max: MAX_ADULTS, age: adult_age
    end
  end

  def slot_details=(date)
    super
    @parsed_slot_details = SlotDetailsParser.new.parse(date)
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
    return true if weekend_processing? && date.on_weekend?

    Rails.configuration.calendar.business_day?(date)
  end

  # rubocop:disable Metrics/LineLength
  def validate_unbookable_dates
    if (unbookable_dates.map(&:date) & anomalous_slots.keys).any?
      errors.add :slot_details, :unbookable_and_anomalous_conflict
    end
    recurring_weekdays = slot_days.map(&:day).map { |r|
      DayOfWeek.by_name(r).index
    }

    unless unbookable_dates.map { |date| recurring_weekdays.include?(date.date.wday) }.all?
      errors.add(:slot_details, :unbookable_date_not_in_schedule)
    end
  end
  # rubocop:enable Metrics/LineLength
end
