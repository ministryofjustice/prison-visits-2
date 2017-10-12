module Nomis
  class Cancellation
    include NonPersistedModel
    attribute :message, String
    attribute :error_message, String

    def error=(error)
      self.error_message = error['message']
    end
  end
end
