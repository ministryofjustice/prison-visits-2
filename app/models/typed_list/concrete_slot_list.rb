class ConcreteSlotList
  include Enumerable

  delegate :each, to: :concrete_slots

  def initialize(concrete_slots = [])
    self.concrete_slots = concrete_slots.dup.freeze

    raise ArgumentError unless concrete_slots.all? { |v| v.is_a?(ConcreteSlot) }
  end

private

  attr_accessor :concrete_slots
end
