module Nomis
  class ContactList
    include NonPersistedModel
    include Enumerable

    delegate :each, to: :contacts

    attribute :contacts, Array[Contact], coercer: lambda { |cts|
      cts.map { |c| Contact.new(c) }
    }
  end
end
