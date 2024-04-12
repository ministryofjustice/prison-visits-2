class SlotsStep
  include MemoryModel

  attribute :option_0, :string
  attribute :option_1, :string
  attribute :option_2, :string
  attribute :vsip_slots

  delegate :available_slots, to: :prison

  validates :option_0, :option_1, :option_2,
            inclusion: { in: lambda { |o|
              if o.prison.estate.vsip_supported
                o.available_slots(vsip_slots: o.vsip_slots)
              else
                o.available_slots.map(&:iso8601)
              end
            } },
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
