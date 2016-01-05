class PrisonSeeder::SeedEntry
  DEFAULT_BOOKING_WINDOW = 28
  DEFAULT_LEAD_DAYS = 3
  DEFAULT_ADULT_AGE = 18

  KEYS = %i[
    address adult_age booking_window email_address enabled estate finder_slug
    lead_days name nomis_id phone_no slot_details weekend_processing
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
    hash.fetch('address', []).join("\n")
  end

  def adult_age
    hash.fetch('adult_age', DEFAULT_ADULT_AGE)
  end

  def booking_window
    hash.fetch('booking_window', DEFAULT_BOOKING_WINDOW)
  end

  def email_address
    hash.fetch('email', nil)
  end

  def enabled
    hash.fetch('enabled', true)
  end

  def estate
    hash.fetch('estate')
  end

  def finder_slug
    hash.fetch('finder_slug') { hash.fetch('name').parameterize }
  end

  def lead_days
    hash.fetch('lead_days', DEFAULT_LEAD_DAYS)
  end

  def name
    hash.fetch('name')
  end

  def nomis_id
    hash.fetch('nomis_id')
  end

  def phone_no
    hash.fetch('phone', nil)
  end

  def slot_details
    {
      'recurring' => hash.fetch('slots', {}),
      'anomalous' => hash.fetch('slot_anomalies', {}),
      'unbookable' => hash.fetch('unbookable', [])
    }
  end

  def weekend_processing
    hash.fetch('works_weekends', false)
  end
end
