class PrisonSeeder
  MissingUuidMapping = Class.new(StandardError)

  def self.seed!(base_path)
    filename_to_uuid_map_path =
      base_path.join('prison_uuid_mappings.yml')
    filename_to_uuid_map =
      YAML.load(File.read(filename_to_uuid_map_path)) || {}
    seeder = new(filename_to_uuid_map)

    Dir[base_path.join('prisons', '*.yml')].each do |path|
      seeder.import path, YAML.load(File.read(path))
    end
  end

  def initialize(filename_to_uuid_map)
    @filename_to_uuid_map = filename_to_uuid_map
  end

  def import(path, hash)
    prison = Prison.find_or_initialize_by(id: uuid_for_path(path))
    entry = PrisonSeeder::SeedEntry.new(hash)
    prison.update! entry.to_h
  end

private

  def uuid_for_path(path)
    filename = File.basename(path)

    unless @filename_to_uuid_map.key?(filename)
      fail MissingUuidMapping, <<-EOF.strip_heredoc
        #{filename} is missing a UUID mapping.
        Rerun `rake maintenance:prison_uuids`, commit the result and rerun
        `rake db:seed`.
      EOF
    end

    @filename_to_uuid_map.fetch(filename)
  end

  class SeedEntry
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
end
