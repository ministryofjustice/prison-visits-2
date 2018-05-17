module Nomis
  class Establishment < Code
    attribute :api_call_successful, :boolean, default: true
    attribute :housing_location, :housing_location

    validates_presence_of :code

    def self.build(response)
      attributes = response['establishment']
      attributes['housing_location'] = response['housing_location'].presence
      new(attributes)
    end

    def api_call_successful?
      api_call_successful
    end
  end
end
