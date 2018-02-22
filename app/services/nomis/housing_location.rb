module Nomis
  class HousingLocation
    include NonPersistedModel
    
    attribute :description, String
    attribute :levels, Array[Hash]
  end
end
