module Nomis
  class OffenderRestrictions
    include NonPersistedModel
    include Enumerable

    delegate :each, to: :restrictions

    attribute :restrictions, Array[Restriction]
    attribute :api_call_successful, Boolean, default: true

    def api_call_successful?
      @api_call_successful
    end
  end
end
