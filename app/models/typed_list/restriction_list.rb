class RestrictionList
  include Enumerable

  delegate :each, to: :restrictions

  def initialize(restrictions = [])
    self.restrictions = restrictions.dup.freeze

    raise ArgumentError unless restrictions.all? { |v| v.is_a?(Nomis::Restriction) }
  end

  def to_a
    restrictions
  end

private

  attr_accessor :restrictions
end
