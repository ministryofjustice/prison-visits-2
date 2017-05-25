module Nomis
  class Establishment
    include NonPersistedModel

    attribute :code
    attribute :desc
    attribute :api_call_successful, Boolean, default: true
    validates_presence_of :code

    def api_call_successful?
      @api_call_successful
    end
  end
end
