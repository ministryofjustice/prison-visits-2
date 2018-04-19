module Nomis
  class ContactList
    include MemoryModel
    include Enumerable

    delegate :each, to: :contacts

    attribute :contacts, :contacts_enumerable, default: []
    attribute :api_call_successful, :boolean, default: true

    def approved
      select(&:approved?)
    end

    def api_call_successful?
      api_call_successful
    end
  end
end
