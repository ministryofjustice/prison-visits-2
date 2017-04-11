module Api
  class AvailableSlotsController < ApiController
    def index
      prison = Prison.find(params.fetch(:prison_id))

      slot_availability = ApiSlotAvailability.new(prison: prison,
                                                  use_nomis_slots: false)

      Timebox.new(TIMEBOX_LIMIT).run do
        slot_availability.restrict_by_prisoner(
          prisoner_number: params.fetch(:prisoner_number),
          prisoner_dob: Date.parse(params.fetch(:prisoner_dob))
        )
      end

      @slots = slot_availability.slots
    end
  end
end
