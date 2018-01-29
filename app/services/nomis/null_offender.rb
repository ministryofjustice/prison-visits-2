module Nomis
  class NullOffender < Offender
    attribute :api_call_successful, :boolean

    def valid?
      false
    end

    def api_call_successful?
      api_call_successful
    end
  end
end
