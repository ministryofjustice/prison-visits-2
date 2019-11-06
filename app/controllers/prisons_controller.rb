# frozen_string_literal: true

class PrisonsController < ApplicationController
  def show
    @prison = Prison.find(params[:id])
  end
end
