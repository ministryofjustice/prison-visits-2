class SlotsStep
  include NonPersistedModel

  attribute :prison, Prison
  attribute :option_1, String
  attribute :option_2, String
  attribute :option_3, String

  delegate :available_slots, to: :prison
end
