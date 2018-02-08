module Nomis
  class AvailabilityVisit
    include NonPersistedModel

    attribute :slot, ConcreteSlot,
      coercer: ->(t) { ApiSlotNormaliser.new(t).slot }
    attribute :id, String
  end
end
