# frozen_string_literal: true
class User < ActiveRecord::Base
  # TODO: Delete me when the column has dropped
  def self.columns
    super.reject { |c| c.name == 'estate_id' }
  end
end
