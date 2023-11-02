class Nomis::Prisoner
  include MemoryModel

  attribute :id, :integer
  attribute :noms_id, :prisoner_number
  alias_attribute :nomis_offender_id, :id

  validates_presence_of :id, :noms_id

  def api_call_successful?
    true
  end

  def iep_level
    return unless Nomis::Api.enabled? && details.valid?

    details.iep_level && details.iep_level['desc']
  end

  def imprisonment_status
    return unless Nomis::Api.enabled? && details.valid?

    details.imprisonment_status['desc']
  end

private

  def details
    @details ||= Nomis::Api.instance
                   .lookup_prisoner_details(noms_id: noms_id)
  rescue Nomis::APIError
    Nomis::Prisoner::Details.new(api_call_successful: false)
  end
end
