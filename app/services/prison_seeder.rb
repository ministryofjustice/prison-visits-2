class PrisonSeeder
  MissingUuidMapping = Class.new(StandardError)
  ImportFailure = Class.new(StandardError)

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
  rescue => err
    raise ImportFailure, "#{err} in #{path}"
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
end
