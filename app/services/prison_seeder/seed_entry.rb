class PrisonSeeder::SeedEntry
  DEFAULT_BOOKING_WINDOW = 28
  DEFAULT_LEAD_DAYS = 3
  DEFAULT_ADULT_AGE = 18

  KEYS = %i[
    address adult_age booking_window email_address enabled lead_days name
    phone_no slot_details weekend_processing
  ]

  def initialize(hash)
    @hash = hash
  end

  def to_h
    KEYS.inject({}) { |a, e| a.merge(e => send(e)) }
  end

private

  attr_reader :hash

  def address
    hash.fetch('address', nil)
  end

  def adult_age
    hash.fetch('adult_age', DEFAULT_ADULT_AGE)
  end

  def booking_window
    hash.fetch('booking_window', DEFAULT_BOOKING_WINDOW)
  end

  def email_address
    hash.fetch('email_address', nil)
  end

  def enabled
    hash.fetch('enabled', true)
  end

  def lead_days
    hash.fetch('lead_days', DEFAULT_LEAD_DAYS)
  end

  def name
    hash.fetch('name')
  end

  def phone_no
    hash.fetch('phone_no', nil)
  end

  def slot_details
    {
      'recurring' => hash.fetch('recurring', {}),
      'anomalous' => hash.fetch('anomalous', {}),
      'unbookable' => hash.fetch('unbookable', [])
    }
  end

  def weekend_processing
    hash.fetch('works_weekends', false)
  end
end
