module Nomis
  class HousingLocation
    include MemoryModel

    attribute :description, :string
    attribute :levels, :level_list
  end
end
