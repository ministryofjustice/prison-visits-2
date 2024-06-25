# frozen_string_literal: true

class InfoController < ApplicationController
  def index
    render json: {
      git: {
        branch: ENV['GIT_BRANCH']
      },
      build: {
        artifact: 'prison-visits-public',
        version: ENV['BUILD_NUMBER'],
        name: 'prison-visits-public'
      },
      productId: ENV['PRODUCT_ID']
    }
  end
end
