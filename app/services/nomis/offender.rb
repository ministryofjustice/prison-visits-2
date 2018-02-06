class Nomis::Offender
  include MemoryModel

  attribute :id, :integer
  attribute :noms_id, :prisoner_number

  validates_presence_of :id, :noms_id

  def api_call_successful?
    true
  end

  def iep_level
    return unless details.valid?
    details.iep_level['desc']
  end

  def imprisonment_status
    return unless details.valid?
    details.imprisonment_status['desc']
  end

private

  def details
    @details ||= Nomis::Api.instance.
                   lookup_offender_details(noms_id: noms_id)
  rescue Nomis::APIError
    Nomis::Offender::Details.new(api_call_successful: false)
  end
end
