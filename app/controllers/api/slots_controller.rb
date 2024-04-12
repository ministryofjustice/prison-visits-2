module Api
  class SlotsController < ApiController
    def index
      # get and set Vsip supported prisons
      VsipSupportedPrisons.new.supported_prisons unless Rails.configuration.vsip_supported_prisons_retrieved

      prison = Prison.enabled.find(params.require(:prison_id))

      if prison.estate.vsip_supported
        @slots = VsipVisitSessions.get_sessions(prison.estate.nomis_id, prisoner_number)
      elsif prison.auto_slots_enabled?
        api_slots = ApiSlotAvailability.new(prison:, use_nomis_slots: true, start_date:, end_date:)
        prisoner_dates = api_slots.prisoner_available_dates(prisoner_number:, prisoner_dob: date_of_birth, start_date:)
        @slots = api_slots.slots.map { |slot| [slot.to_s, prisoner_dates.include?(slot.to_date) ? [] : [SlotAvailability::PRISONER_UNAVAILABLE]] }.to_h
      else
        SlotAvailability.new(prison, prisoner_number, date_of_birth, start_date..end_date).slots
        @slots = SlotAvailability.new(prison, prisoner_number, date_of_birth, start_date..end_date).slots
      end
    end

  private

    def prisoner_number
      params.require(:prisoner_number)
    end

    def date_of_birth
      params.require(:prisoner_dob)
    end

    def start_date
      Date.parse(params.require(:start_date))
    end

    def end_date
      Date.parse(params.require(:end_date))
    end
  end
end
