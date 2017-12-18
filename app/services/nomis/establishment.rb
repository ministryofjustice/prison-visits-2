module Nomis
  class Establishment
    include NonPersistedModel

    attribute :code
    attribute :desc
    attribute :api_call_successful, Boolean, default: true
    attribute :housing_location, String

    validates_presence_of :code

    def self.build(response)
      attributes = response['establishment']
      attributes['housing_location'] = response['housing_location'].presence
      new(attributes)
    end

    def api_call_successful?
      @api_call_successful
    end
  end
end
