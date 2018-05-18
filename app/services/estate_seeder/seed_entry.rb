class EstateSeeder::SeedEntry
  KEYS = %i[ nomis_id name finder_slug sso_organisation_name group admins ].freeze

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

  def sso_organisation_name
    label = name.downcase.gsub(/\s+-\s+/, '-').gsub(/\s+/, '_')
    "#{label}.prisons.noms.moj"
  end

  def group
    hash['group']
  end

  def admins
    hash['admins']
  end
end
