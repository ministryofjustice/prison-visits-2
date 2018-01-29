module Nomis
  class ApiSlot
    include MemoryModel

    attribute :time, :normalised_concrete_slot
    attribute :capacity, :integer
    attribute :max_groups, :integer
    attribute :max_adults, :integer
    attribute :groups_booked, :integer
    attribute :visitors_booked, :integer
    attribute :adults_booked, :integer

    delegate :to_s, :to_date, to: :time

    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
