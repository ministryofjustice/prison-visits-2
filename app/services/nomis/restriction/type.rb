module Nomis
  class Restriction
    class Type
      include MemoryModel

      attribute :code, :string
      attribute :desc, :string
    end
  end
end
