module Nomis
  class ApiSlotNormaliser
    def initialize(raw_slot)
      @raw_slot = ConcreteSlot.parse(raw_slot)
    end

    def slot
      return @raw_slot if valid_times?

      ConcreteSlot.parse_times(
        normalise_time(@raw_slot.begin_at),
        normalise_time(@raw_slot.end_at))
    end

  private

    def normalise_time(time)
      if time.min.in?([59, 14, 29, 44])
        time + 1.minute
      elsif time.min.in?([1, 16, 31, 46])
        time - 1.minute
      else
        time
      end
    end

    def valid_times?
      valid_time?(@raw_slot.begin_at) &&
        valid_time?(@raw_slot.end_at)
    end

    def valid_time?(time)
      time.min % 5 == 0
    end
  end
end
