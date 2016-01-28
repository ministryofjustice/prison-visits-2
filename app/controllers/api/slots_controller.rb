module Api
  class SlotsController < ApiController
    def index
      prison = Prison.enabled.find(params[:prison_id])
      @slots = prison.available_slots
    end
  end
end
