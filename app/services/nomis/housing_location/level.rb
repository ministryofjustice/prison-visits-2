module Nomis
  class HousingLocation
    class Level
      include MemoryModel

      attribute :type,  :string
      attribute :value, :string
    end
  end
end
