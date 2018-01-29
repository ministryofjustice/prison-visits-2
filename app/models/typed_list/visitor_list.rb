class VisitorList
  include Enumerable

  delegate :each, to: :visitors

  def initialize(visitors = [])
    self.visitors = visitors.dup.freeze

    raise ArgumentError unless visitors.all? { |v| v.is_a?(Visitor) }
  end

  def to_a
    visitors
  end

private

  attr_accessor :visitors
end
