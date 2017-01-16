# frozen_string_literal: true
module NonPersistedModel
  extend ActiveSupport::Concern

  included do
    include Virtus.model
    include ActiveModel::Conversion
    include ActiveModel::Validations

    def persisted?
      false
    end
  end
end
