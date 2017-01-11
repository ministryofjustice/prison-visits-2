# frozen_string_literal: true
module Nomis
  class Offender
    include NonPersistedModel

    attribute :id

    validates_presence_of :id

    def api_call_successful?
      true
    end
  end
end
