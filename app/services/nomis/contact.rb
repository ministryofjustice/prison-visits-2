module Nomis
  class Contact
    include NonPersistedModel

    attribute :id
    attribute :given_name
    attribute :surname
    attribute :date_of_birth, Date
    attribute :gender, Hash[Symbol => String]
    attribute :relationship_type, Hash[Symbol => String]
    attribute :contact_type, Hash[Symbol => String]
    attribute :approved_visitor, Boolean
    attribute :active, Boolean
    attribute :restrictions, Array[ContactRestriction]
  end
end
