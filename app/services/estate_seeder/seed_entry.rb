class EstateSeeder::SeedEntry
  KEYS = %i[ nomis_id name finder_slug ]

  def initialize(nomis_id, hash)
    @nomis_id = nomis_id
    @hash = hash
  end

  def to_h
    KEYS.inject({}) { |a, e| a.merge(e => send(e)) }
  end

private

  attr_reader :hash, :nomis_id

  def finder_slug
    hash.fetch('finder_slug') { hash.fetch('name').parameterize }
  end

  def name
    hash.fetch('name')
  end
end
