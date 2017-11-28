module Nomis
  class Establishment
    include NonPersistedModel

    attribute :code
    attribute :desc
    attribute :api_call_successful, Boolean, default: true
    attribute :internal_location, String

    validates_presence_of :code

    def self.build(response)
      attributes = response['establishment']
      if response['internal_location'].present?
        attributes['internal_location'] = response['internal_location']
      end

      new(attributes)
    end

    def api_call_successful?
      @api_call_successful
    end
  end
end
