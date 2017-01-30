module Nomis
  class SlotAvailability
    include Enumerable
    include NonPersistedModel

    attribute :slots, Array[ApiSlot], coercer: lambda { |slots|
      slots.map { |s| ApiSlot.new(s) }
    }

    def each
      slots.each { |slot| yield slot }
    end
  end
end
