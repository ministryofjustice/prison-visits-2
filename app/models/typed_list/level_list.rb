class LevelList
  include Enumerable
  delegate :each, to: :levels

  def initialize(levels = [])
    self.levels = levels.dup.freeze

    raise ArgumentError unless levels.all? { |l| l.is_a?(Nomis::HousingLocation::Level) }
  end

private

  attr_accessor :levels
end
