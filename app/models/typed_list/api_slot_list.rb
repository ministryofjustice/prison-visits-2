class ApiSlotList
  include Enumerable

  delegate :each, to: :api_slots

  def initialize(api_slots = [])
    self.api_slots = api_slots.dup.freeze

    raise ArgumentError unless api_slots.all? { |a| a.is_a?(Nomis::ApiSlot) }
  end

private

  attr_accessor :api_slots
end
