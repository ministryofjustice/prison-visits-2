class PingController < ApplicationController
  def index
    render json: Rails.application.config.version_info
  end
end
