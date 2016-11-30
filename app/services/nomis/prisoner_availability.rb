module Nomis
  class PrisonerAvailability
    include NonPersistedModel

    attribute :dates, Array
  end
end
