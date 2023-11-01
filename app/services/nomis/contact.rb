module Nomis
  class Contact
    include MemoryModel
    include Comparable

    attribute :id,                :integer
    attribute :given_name,        :string
    attribute :middle_names,      :string
    attribute :surname,           :string
    attribute :date_of_birth,     :date
    attribute :gender,            :contact_gender
    attribute :relationship_type, :contact_relationship
    attribute :contact_type,      :contact_type
    attribute :approved_visitor,  :boolean
    attribute :active,            :boolean
    attribute :restrictions,      :restriction_list

    def attributes
      {
        'id' => id,
        'given_name' => given_name,
        'surname' => surname,
        'date_of_birth' => date_of_birth,
        'gender' => gender,
        'relationship_type' => relationship_type,
        'contact_type' => contact_type,
        'approved_visitor' => approved_visitor,
        'active' => active,
        'restrictions' => restrictions
      }
    end

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
