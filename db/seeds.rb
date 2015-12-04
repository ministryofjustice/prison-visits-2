Prison.transaction do
  prison_uuid_mapping_path =
    Rails.root.join('db', 'seeds', 'prison_uuid_mappings.yml')

  prison_uuid_mappings = YAML.load(File.read(prison_uuid_mapping_path)) || {}

  Dir[Rails.root.join('db', 'seeds', 'prisons', '*.yml')].each do |path|
    hash = YAML.load(File.read(path))
    filename = Pathname.new(path).basename.to_s

    if prison_uuid_mappings[filename].blank?
      fail Prison::MissingUuidMapping, <<-EOF.strip_heredoc
        #{filename} is missing a UUID mapping. Rerun `rake maintenance:prison_uuids`,
        commit the result and rerun `rake db:seed`.
      EOF
    end

    prison = Prison.find_or_initialize_by(id: prison_uuid_mappings[filename])

    prison.update!(
      address: hash.fetch('address', []).join("\n"),
      booking_window: hash.fetch('booking_window', 28),
      lead_days: hash.fetch('lead_days', 3),
      weekend_processing: hash.fetch('works_weekends', false),
      email_address: hash.fetch('email', nil),
      enabled: hash.fetch('enabled', true),
      estate: hash.fetch('estate'),
      id: prison_uuid_mappings[filename],
      name: hash.fetch('name'),
      nomis_id: hash.fetch('nomis_id'),
      phone_no: hash.fetch('phone', nil),
      slot_details: {
        'recurring' => hash.fetch('slots', {}),
        'anomalous' => hash.fetch('slot_anomalies', {}),
        'unbookable' => hash.fetch('unbookable', [])
      }
    )
  end
end
