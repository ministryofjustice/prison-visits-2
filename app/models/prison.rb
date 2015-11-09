class Prison < ActiveRecord::Base
  MissingUuidMapping = Class.new(StandardError)

  has_many :visits

  validates :estate, :name, :nomis_id, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  alias_attribute :email, :email_address

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
    today + 1
  end

  def last_bookable_date(today = Time.zone.today)
    first_bookable_date(today) + booking_window - 1
  end
end
