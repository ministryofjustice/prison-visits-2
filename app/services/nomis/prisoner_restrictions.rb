module Nomis
  class PrisonerRestrictions
    include MemoryModel
    include Enumerable

    delegate :each, to: :restrictions

    attribute :restrictions, :restriction_list, default: -> { [] }
    attribute :api_call_successful, :boolean, default: true

    def api_call_successful?
      api_call_successful
    end
  end
end
