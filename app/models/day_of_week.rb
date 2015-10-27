class DayOfWeek
  def self.by_name(name)
    ALL.find { |d| d.name == name }
  end

  def self.by_index(index)
    ALL.fetch(index)
  end

  def initialize(name, index)
    @name = name
    @index = index
  end

  attr_reader :name, :index

  ALL = [
    SUN = new('sun', 0),
    MON = new('mon', 1),
    TUE = new('tue', 2),
    WED = new('wed', 3),
    THU = new('thu', 4),
    FRI = new('fri', 5),
    SAT = new('sat', 6)
  ]

  # These should be singletons, so ensure that no more can be created
  def self.new(*)
    fail ArgumentError
  end
end
