module NonPersistedModel
  extend ActiveSupport::Concern

  included do
    include Virtus.model
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    def persisted?
      false
    end
  end
end
