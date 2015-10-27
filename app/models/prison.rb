class Prison < ActiveRecord::Base
  has_many :visits

  validates :estate, :name, :nomis_id, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  def self.enabled
    where(enabled: true).order(name: :asc)
  end

  def available_slots(today = Time.zone.today)
    parser = SlotDetailsParser.new(slot_details)
    AvailableSlotEnumerator.new(
      today + 1,
      parser.recurring_slots,
      parser.anomalous_slots,
      parser.unbookable_dates,
      booking_window
    )
  end
end
