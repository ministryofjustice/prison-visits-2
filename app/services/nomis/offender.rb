class Nomis::Offender
  include NonPersistedModel

  attribute :id
  attribute :noms_id,
    String,
    coercer: ->(number) { number&.upcase&.strip }

  validates_presence_of :id, :noms_id

  def api_call_successful?
    true
  end
end
