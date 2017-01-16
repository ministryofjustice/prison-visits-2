# frozen_string_literal: true
module Api
  class PrisonsController < ApiController
    def index
      @prisons = scope.all
    end

    def show
      @prison = scope.find(params[:id])
    end

  private

    def scope
      Prison.enabled
    end
  end
end
