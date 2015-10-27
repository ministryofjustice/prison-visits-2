module NonPersistedModel
  module InstanceMethods
    def persisted?
      false
    end
  end

  def self.included(receiver)
    receiver.send :include, Virtus.model
    receiver.send :include, ActiveModel::Conversion
    receiver.send :include, ActiveModel::Validations
    receiver.send :include, InstanceMethods
  end
end
