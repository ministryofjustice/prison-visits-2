# frozen_string_literal: true

# :nocov:
module Nomis
  class UserDetails
    attr_reader :first_name,
                :last_name

    def initialize(payload)
      @first_name = payload['firstName']
      @last_name = payload['lastName']
    end
  end
end
# :nocov:
