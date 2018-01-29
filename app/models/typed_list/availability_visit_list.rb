class AvailabilityVisitList
  include Enumerable

  delegate :each, to: :availability_visits

  def initialize(availability_visits = [])
    self.availability_visits = availability_visits.dup.freeze

    unless availability_visits.all? { |a| a.is_a?(Nomis::AvailabilityVisit) }
      raise ArgumentError
    end
  end

private

  attr_accessor :availability_visits
end
