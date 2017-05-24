module Nomis
  class ContactList
    include NonPersistedModel
    include Enumerable

    delegate :each, to: :contacts

    attribute :contacts, Array[Contact]
    attribute :api_call_successful, Boolean, default: true

    def approved
      select { |contact| contact.approved? }
    end

    def api_call_successful?
      @api_call_successful
    end
  end
end
