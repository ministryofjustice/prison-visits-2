module Nomis
  class ContactList
    include NonPersistedModel
    include Enumerable

    delegate :each, to: :contacts

    attribute :contacts,
      Array[Contact],
      coercer: ->(contacts) { contacts.map { |s| Contact.new(s) }.sort }

    attribute :api_call_successful, Boolean, default: true

    def approved
      select(&:approved?)
    end

    def api_call_successful?
      @api_call_successful
    end
  end
end
