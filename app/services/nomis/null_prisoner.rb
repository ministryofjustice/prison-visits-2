module Nomis
  class NullPrisoner < Prisoner
    attribute :api_call_successful, :boolean

    def valid?
      false
    end

    def iep_level; end

    def imprisonment_status; end

    def api_call_successful?
      api_call_successful
    end
  end
end
