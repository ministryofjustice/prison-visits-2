namespace :maintenance do
  task prison_uuids: :environment do
    prison_uuid_mapping_path =
      Rails.root.join('db', 'seeds', 'prison_uuid_mappings.yml')

    prison_uuid_mappings = YAML.load(File.read(prison_uuid_mapping_path)) || {}

    Dir[Rails.root.join('db', 'seeds', 'prisons', '*.yml')].each do |path|
      filename = Pathname.new(path).basename.to_s
      if prison_uuid_mappings[filename]
        puts "Mapping exists for #{filename}. Skipping."
      else
        puts "No mapping for #{filename}. Generating."
        prison_uuid_mappings[filename] = SecureRandom.uuid
      end

      YAML.dump(
        prison_uuid_mappings,
        prison_uuid_mapping_path
      )
    end
  end
end
