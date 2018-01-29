module Nomis
  class PrisonerAvailability
    include MemoryModel

    attribute :available, :boolean
    attribute :dates, :date_list
  end
end
