module MemoryModel
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
  end
end
