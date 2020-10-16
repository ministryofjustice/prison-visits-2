module Api
  class SlotsController < ApiController
    def index
      prison = Prison.enabled.find(params.require(:prison_id))

      if prison.auto_slots_enabled?
        api_slots = ApiSlotAvailability.new(prison: prison, use_nomis_slots: true, start_date: start_date, end_date: end_date)
        prisoner_dates = api_slots.prisoner_available_dates(prisoner_number: prisoner_number, prisoner_dob: date_of_birth, start_date: start_date)
        @slots = api_slots.slots.map { |slot| [slot.to_s, prisoner_dates.include?(slot.to_date) ? [] : [SlotAvailability::PRISONER_UNAVAILABLE]] }.to_h
      else
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
