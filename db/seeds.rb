Prison.transaction do
  path = Rails.root.join('db', 'seeds')
  EstateSeeder.seed! path
  PrisonSeeder.seed! path
end