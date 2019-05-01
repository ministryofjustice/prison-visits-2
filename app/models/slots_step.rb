class SlotsStep
  include MemoryModel

  attribute :option_0, :string
  attribute :option_1, :string
  attribute :option_2, :string

  delegate :available_slots, to: :prison

  validates :option_0, :option_1, :option_2,
            inclusion: { in: ->(o) { o.available_slots.map(&:iso8601) } },
            allow_blank: true
  validates :option_0, presence: true

  attr_accessor :prison

  def slots
    options.map { |s| ConcreteSlot.parse(s) }
  end

private

  def options
    [option_0, option_1, option_2].select(&:present?)
  end
end
