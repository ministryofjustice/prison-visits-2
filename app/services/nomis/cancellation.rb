module Nomis
  class Cancellation
    include MemoryModel
    attribute :message, :string
    attribute :error_message, :string

    def error=(error)
      self.error_message = error['message']
    end
  end
end
