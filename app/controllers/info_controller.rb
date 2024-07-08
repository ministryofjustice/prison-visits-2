# frozen_string_literal: true

class InfoController < ApplicationController
  def index
    render json: {
      git: {
        branch: ENV['GIT_BRANCH']
      },
      build: {
        artifact: 'prison-visits-2',
        version: ENV['BUILD_NUMBER'],
        name: 'prison-visits-2'
      },
      productId: ENV['PRODUCT_ID']
    }
  end
end
