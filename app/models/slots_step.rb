class SlotsStep
  include NonPersistedModel

  attribute :prison, Prison
  attribute :option_1, String
  attribute :option_2, String
  attribute :option_3, String

  delegate :available_slots, to: :prison

  validates :option_1, :option_2, :option_3,
    inclusion: { in: ->(o) { o.available_slots.map(&:iso8601) } },
    allow_blank: true
  validates :option_1, presence: true
end
