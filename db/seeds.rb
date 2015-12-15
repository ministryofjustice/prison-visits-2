Prison.transaction do
  PrisonSeeder.seed! Rails.root.join('db', 'seeds')
end
