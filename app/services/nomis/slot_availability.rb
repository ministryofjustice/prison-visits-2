module Nomis
  class SlotAvailability
    include Enumerable
    include MemoryModel

    attribute :slots, :api_slot_list

    def each(&block)
      slots.each(&block)
    end
  end
end
