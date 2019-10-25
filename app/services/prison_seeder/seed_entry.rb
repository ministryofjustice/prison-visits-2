class PrisonSeeder::SeedEntry
  DEFAULT_BOOKING_WINDOW = 28
  DEFAULT_LEAD_DAYS = 3
  DEFAULT_ADULT_AGE = 18

  KEYS = %i[
    address adult_age booking_window email_address enabled lead_days name
    phone_no postcode slot_details translations weekend_processing closed private
  ]

  def initialize(prison, hash)
    @prison = prison
    @hash = hash
  end

  def to_h
    KEYS.inject({}) { |a, e| a.merge(e => send(e)) }
  end

  def unbookable_dates
    today = Time.zone.today
    (hash_unbookable_slots + unbookable_slots).
      select { |unbookable_date| unbookable_date > today }.
      sort.uniq
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

  def closed
    hash.fetch('closed')
  end

  def private
    hash.fetch('private')
  end

  def phone_no
    hash.fetch('phone_no', nil)
  end

  def postcode
    hash.fetch('postcode', nil)
  end

  def slot_details
    today = Time.zone.today.to_s
    {
      'recurring' => hash.fetch('recurring', {}),
      'anomalous' => hash.fetch('anomalous', {})
    }
  end

  def translations
    hash.fetch('translations', {})
  end

  def weekend_processing
    hash.fetch('works_weekends', false)
  end

private

  # hashes coming in from YML files actually contain dates
  def hash_unbookable_slots
    hash.fetch('unbookable', [])
  end

  def unbookable_slots
    @prison.unbookable_dates.map(&:date)
  end
end
