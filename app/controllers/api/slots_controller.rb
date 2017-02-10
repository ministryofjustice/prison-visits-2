module Api
  class SlotsController < ApiController
    def index
      prison = Prison.enabled.find(params.require(:prison_id))
      @slots = PrisonerSlotAvailability.new(
        prison, prisoner_number, date_of_birth, start_date, end_date
      ).slots
    end

  private

    def prisoner_number
      params.require(:prisoner_number)
    end

    def date_of_birth
      params.require(:prisoner_number)
    end

    def start_date
      params.require(:start_date)
    end

    def end_date
      params.require(:end_date)
    end
  end
end
