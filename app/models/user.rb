class User < ApplicationRecord
  # TODO: Delete me when the column has dropped
  def self.columns
    super.reject { |c| c.name == 'estate_id' }
  end
end
