module Nomis
  class Establishment
    include MemoryModel

    attribute :code, :string
    attribute :desc, :string
    attribute :api_call_successful, :boolean, default: true
    attribute :housing_location, :string

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
