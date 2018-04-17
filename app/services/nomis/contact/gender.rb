module Nomis
  class Contact
    class Gender
      include MemoryModel

      attribute :code, :string
      attribute :desc, :string
    end
  end
end
