class PrisonerDateAvailabilityList
  include Enumerable

  delegate :each, to: :dates

  def initialize(dates = [])
    self.dates = dates.dup.freeze

    raise ArgumentError unless dates.all? { |d| d.is_a?(Nomis::PrisonerDateAvailability) }
  end

private

  attr_accessor :dates
end
