class PrisonSeeder
  MissingUuidMapping = Class.new(StandardError)
  ImportFailure = Class.new(StandardError)

  def self.seed!(base_path)
    filename_to_uuid_map_path =
      base_path.join('prison_uuid_mappings.yml')
    filename_to_uuid_map =
      YAML.load(File.read(filename_to_uuid_map_path)) || {}
    seeder = new(Rails.logger, filename_to_uuid_map)

    Dir[base_path.join('prisons', '*.yml')].each do |path|
      seeder.import path, YAML.load(File.read(path))
    end
  end

  def initialize(logger, filename_to_uuid_map)
    @logger = logger
    @filename_to_uuid_map = filename_to_uuid_map
  end

  # rubocop:disable Metrics/MethodLength
  def import(path, hash)
    Prison.transaction do
      estate = Estate.find_by!(nomis_id: hash.fetch('nomis_id'))
      prison = Prison.includes(:unbookable_dates).
        find_or_initialize_by(id: uuid_for_path(path))
      entry = PrisonSeeder::SeedEntry.new(prison, hash)
      prison.update! entry.to_h.merge(estate: estate)

      import_unbookable_dates(prison, entry)
      import_slot_days(prison, entry)
    end
  rescue StandardError => e
    raise ImportFailure, "#{e} in #{path}"
  end
# rubocop:enable Metrics/MethodLength

private

  # rubocop:disable Metrics/MethodLength
  def import_slot_days(prison, entry)
    # updating these is too hard - so just remove and put back
    # (which is what used to happen anyway when it was stored as JSON)
    prison.slot_days.destroy_all

    entry.recurring_slots.each do |day, slots|
      slot_day = prison.slot_days.create!(start_date: Time.zone.today, day: day)
      slots.each do |slot|
        slot_data = RecurringSlot.parse(slot)
        slot_day.slot_times.create!(begin_hour: slot_data.begin_hour,
                                    begin_minute: slot_data.begin_minute,
                                    end_hour: slot_data.end_hour,
                                    end_minute: slot_data.end_minute)
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  attr_accessor :logger

  def import_unbookable_dates(prison, entry)
    entry.unbookable_dates.
      each do |date|
      unbookable = prison.unbookable_dates.create(date: date)
      unless unbookable.valid?
        logger.warn "create unbookable date #{date} fail at #{prison.estate.nomis_id}"
      end
    end
  end

  def uuid_for_path(path)
    filename = File.basename(path)

    unless @filename_to_uuid_map.key?(filename)
      fail MissingUuidMapping, <<-MESSAGE.strip_heredoc
        #{filename} is missing a UUID mapping.
        Rerun `rake maintenance:prison_uuids`, commit the result and rerun
        `rake db:seed`.
      MESSAGE
    end

    @filename_to_uuid_map.fetch(filename)
  end
end
