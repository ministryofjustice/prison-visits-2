module Nomis
  class Contact
    class Relationship
      include MemoryModel

      attribute :code, :string
      attribute :desc, :string
    end
  end
end
