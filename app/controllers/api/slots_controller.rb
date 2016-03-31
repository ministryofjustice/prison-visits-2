module Api
  class SlotsController < ApiController
    def index
      prison = Prison.enabled.find(params.fetch(:prison_id))

      slot_availability = SlotAvailability.new(prison: prison)
      slot_availability.restrict_by_prisoner(
        prisoner_number: params.fetch(:prisoner_number),
        prisoner_dob: Date.parse(params.fetch(:prisoner_dob))
      )

      @slots = slot_availability.slots
    end
  end
end
