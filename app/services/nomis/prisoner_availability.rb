module Nomis
  class PrisonerAvailability
    include NonPersistedModel

    attribute :available, Boolean
    attribute :dates, Array[Date]
  end
end
