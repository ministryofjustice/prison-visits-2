module Api
  class SlotsController < ApiController
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def index
      prison = Prison.enabled.find(params.fetch(:prison_id))

      # Temporarily introduce this API parameter to facilitate experimentation
      # (Note: using string 'true' because this is a GET parameter)
      use_nomis = params.fetch(:use_nomis_slots, nil) == 'true'

      slot_availability = SlotAvailability.new(
        prison: prison,
        use_nomis_slots: use_nomis
      )
      slot_availability.restrict_by_prisoner(
        prisoner_number: params.fetch(:prisoner_number),
        prisoner_dob: Date.parse(params.fetch(:prisoner_dob))
      )

      @slots = slot_availability.slots
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
