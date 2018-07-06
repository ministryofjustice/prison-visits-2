module Nomis
  class Offender
    class Availability
      include MemoryModel

      attribute :available, :boolean
      attribute :dates, :date_list
    end
  end
end
