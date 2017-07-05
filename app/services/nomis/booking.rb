module Nomis
  class Booking
    include NonPersistedModel

    attribute :visit_id, Integer
    attribute :error_message, String

    def self.build(response)
      if response.key?('error')

        new(error_message: response['error']['message'])
      else
        new(visit_id: response['visit_id'])
      end
    end
  end
end
