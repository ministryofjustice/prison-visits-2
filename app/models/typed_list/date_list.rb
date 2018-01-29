class DateList
  include Enumerable

  delegate :each, to: :dates

  def initialize(dates = [])
    raise ArgumentError unless dates.all? { |v| v.is_a?(Date) }

    self.dates = dates.dup.freeze
  end

private

  attr_accessor :dates
end
