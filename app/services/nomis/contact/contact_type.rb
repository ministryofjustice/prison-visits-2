module Nomis
  class Contact
    class ContactType
      include MemoryModel

      attribute :code, :string
      attribute :desc, :string
    end
  end
end
