module Nomis
  class ApiSlot
    include NonPersistedModel

    attribute :time, ConcreteSlot, coercer: ->(t) { ConcreteSlot.parse(t) }
    attribute :capacity, Integer
    attribute :max_groups, Integer
    attribute :max_adults, Integer
    attribute :groups_booked, Integer
    attribute :visitors_booked, Integer
    attribute :adults_booked, Integer

    delegate :to_s, :to_date, to: :time

    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
