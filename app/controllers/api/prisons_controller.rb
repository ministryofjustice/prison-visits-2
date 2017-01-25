module Api
  class PrisonsController < ApiController
    def index
      @prisons = Prison.order(name: :asc).all
    end

    def show
      @prison = Prison.find(params[:id])
    end
  end
end
