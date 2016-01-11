class EstateSeeder
  ImportFailure = Class.new(StandardError)

  def self.seed!(base_path)
    estates = YAML.load(File.read(base_path.join('estates.yml')))
    seeder = new
    estates.each do |nomis_id, attributes|
      seeder.import nomis_id, attributes
    end
  end

  def import(nomis_id, attributes)
    estate = Estate.find_or_initialize_by(nomis_id: nomis_id)
    entry = EstateSeeder::SeedEntry.new(nomis_id, attributes)
    estate.update! entry.to_h
  end
end
