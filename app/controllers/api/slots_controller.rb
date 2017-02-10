module Api
  class SlotsController < ApiController

    def index
      PrisonerSlotAvailability.new()
    end

    private

    def prisoner

    end
  end
end
