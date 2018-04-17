module Nomis
  class OffenderRestrictions
    include MemoryModel
    include Enumerable

    delegate :each, to: :restrictions

    attribute :restrictions, :restriction_list, default: -> { RestrictionList.new }
    attribute :api_call_successful, :boolean, default: true

    def api_call_successful?
      api_call_successful
    end
  end
end
