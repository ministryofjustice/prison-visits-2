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

  def options_available?
    options.length < 3
  end

  def additional_options?
    options.length > 1
  end

  def slots
    options.map { |s| ConcreteSlot.parse(s) }
  end

  def options
    [option_1, option_2, option_3].select(&:present?)
  end
end
