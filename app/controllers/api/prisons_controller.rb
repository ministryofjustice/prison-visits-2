module Api
  class PrisonsController < ApiController
    def index
      # temporarily filter out ALI so no new visit
      # requests are sent to ALI
      @prisons = Prison.joins(:estate).
                   where.not(
                     estates: { nomis_id: 'ALI' }
                   ).order(name: :asc).all
    end

    def show
      @prison = Prison.find(params[:id])
    end
  end
end
