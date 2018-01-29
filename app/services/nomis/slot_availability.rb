module Nomis
  class SlotAvailability
    include Enumerable
    include MemoryModel

    attribute :slots, :api_slot_list

    def each
      slots.each { |slot| yield slot }
    end
  end
end
