module Api
  class PrisonsController < ApiController
    def index
      # temporarily filter out ALI so no new visit
      # requests are sent to ALI
      albany = Estate.find_by!(nomis_id: 'ALI')
      @prisons = Prison.where.not(estate_id: albany.id).order(name: :asc).all
    end

    def show
      @prison = Prison.find(params[:id])
    end
  end
end
