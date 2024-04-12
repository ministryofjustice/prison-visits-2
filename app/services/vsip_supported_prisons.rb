class VsipSupportedPrisons
  def supported_prisons
    @vsip_enabled_prisons = if Vsip::Api.enabled?
                              Rails.configuration.vsip_supported_prisons_retrieved = true
                              Vsip::Api.instance.supported_prisons
                            else
                              Vsip::NullSupportedPrisons.new(api_call_successful: false)
                            end
  end
end
