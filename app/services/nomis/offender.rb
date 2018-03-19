require 'maybe_date'

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

  def iep_level
    return unless details.valid?
    details[:iep_level][:desc]
  end

  def imprisonment_status
    return unless details.valid?
    details[:imprisonment_status][:desc]
  end

private

  def details
    @details ||= Nomis::Api.instance.lookup_offender_details(noms_id: noms_id)
  rescue Nomis::DisabledError
    Rails.logger.warn "Nomis API disabled!"
    create_offender_details
  rescue Nomis::APIError , Nomis::DisabledError
    create_offender_details
  end

  def create_offender_details
    Nomis::Offender::Details.new(api_call_successful: false)
  end
end
