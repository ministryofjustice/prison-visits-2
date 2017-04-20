module Api
  class SlotsController < ApiController
    def index
      prison = Prison.enabled.find(params.require(:prison_id))
      slot_availability = SlotAvailability.new(
        prison, prisoner_number, date_of_birth, start_date..end_date)

      @slots = slot_availability.slots
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
