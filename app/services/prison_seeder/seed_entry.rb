class PrisonSeeder::SeedEntry
  OVERRIDE_KEY = 'OVERRIDE_PRISON_EMAIL_DOMAIN'
  DEFAULT_BOOKING_WINDOW = 28
  DEFAULT_LEAD_DAYS = 3
  DEFAULT_ADULT_AGE = 18

  KEYS = %i[
    address adult_age booking_window email_address enabled lead_days name
    phone_no postcode slot_details translations weekend_processing
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
    if ENV.key?(OVERRIDE_KEY)
      'pvb2.%s@%s' % [name.parameterize, ENV.fetch(OVERRIDE_KEY)]
    else
      hash.fetch('email_address', nil)
    end
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

  def postcode
    hash.fetch('postcode', nil)
  end

  def slot_details
    {
      'recurring' => hash.fetch('recurring', {}),
      'anomalous' => hash.fetch('anomalous', {}),
      'unbookable' => hash.fetch('unbookable', [])
    }
  end

  def translations
    hash.fetch('translations', {})
  end

  def weekend_processing
    hash.fetch('works_weekends', false)
  end
end
