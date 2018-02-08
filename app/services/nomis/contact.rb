module Nomis
  class Contact
    include NonPersistedModel
    include Comparable

    attribute :id, Integer
    attribute :given_name
    attribute :surname
    attribute :date_of_birth, Date
    attribute :gender, Hash[Symbol => String]
    attribute :relationship_type, Hash[Symbol => String]
    attribute :contact_type, Hash[Symbol => String]
    attribute :approved_visitor, Boolean
    attribute :active, Boolean
    attribute :restrictions, Array[Restriction]

    def full_name
      "#{given_name} #{surname}".downcase
    end

    def approved?
      approved_visitor
    end

    def banned?
      restrictions.any?(&:banned?)
    end

    def banned_until
      restrictions.find(&:banned?)&.expiry_date
    end

    def <=>(other)
      [surname, given_name] <=> [other.surname, other.given_name]
    end
  end
end
