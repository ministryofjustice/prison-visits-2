module Nomis
  class AvailabilityVisit
    include MemoryModel

    attribute :slot, :normalised_concrete_slot
    attribute :id, :string
  end
end
