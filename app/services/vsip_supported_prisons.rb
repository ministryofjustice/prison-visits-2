class VsipSupportedPrisons
  def initialize
    @vsip_enabled_prisons = if Vsip::Api.enabled?
                  Vsip::Api.instance.supported_prisons
                else
                  Vsip::NullPrisoner.new(api_call_successful: false)
                end
  end

  def valid?
    error.nil? || error == PrisonerValidation::UNKNOWN
  end

  def error
    prisoner_validation.errors[:base].first
  end
end