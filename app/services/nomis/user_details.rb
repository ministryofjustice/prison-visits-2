# frozen_string_literal: true

# simplecov:disable
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
# simplecov:disable
