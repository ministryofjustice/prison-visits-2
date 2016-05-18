class SlotsStep
  include NonPersistedModel

  attribute :prison, Prison
  attribute :option_0, String
  attribute :option_1, String
  attribute :option_2, String

  delegate :available_slots, to: :prison

  validates :option_0, :option_1, :option_2,
    inclusion: { in: ->(o) { o.available_slots.map(&:iso8601) } },
    allow_blank: true
  validates :option_0, presence: true

  def slots
    options.map { |s| ConcreteSlot.parse(s) }
  end

private

  def options
    [option_0, option_1, option_2].select(&:present?)
  end
end
