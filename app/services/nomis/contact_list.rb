module Nomis
  class ContactList
    include NonPersistedModel
    include Enumerable

    delegate :each, to: :contacts

    attribute :contacts, Array[Contact]

    def approved
      select { |contact| contact.approved? && contact.active? }
    end
  end
end
