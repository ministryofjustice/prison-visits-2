module Nomis
  class Booking
    include MemoryModel

    attribute :visit_id, :integer
    attribute :error_messages, default: -> { [] }
    attribute :error_message # Deprecated

    def self.build(response)
      if response.key?('visit_id')
        new(visit_id: response['visit_id'])
      elsif response.key?('error')
        new(error_messages: [response['error']['message']])
      else
        new(error_messages: parse_multiple_errors(response))
      end
    end

    def self.parse_multiple_errors(response)
      response.fetch('errors').map { |error| error.fetch('message') }
    end
  end
end
