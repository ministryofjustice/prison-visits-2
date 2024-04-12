class VsipVisitSessions
  def self.get_sessions(nomid_id, prisoner_number)
    @vsip_enabled_prisons = if Vsip::Api.enabled?
                              Vsip::Api.instance.visit_sessions(nomid_id, prisoner_number)
                            else
                              Vsip::NullSupportedPrisons.new(api_call_successful: false)
                            end
  end
end
