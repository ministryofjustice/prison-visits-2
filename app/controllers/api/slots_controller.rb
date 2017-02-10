module Api
  class SlotsController < ApiController

    def index
      PrisonerSlotAvailability.new()
    end

    private

    def prisoner
      Nomis::Api.instance.lookup_active_offender(
        noms_id: params[:prisoner_id], date_of_birth:
      )
    end
  end
end
