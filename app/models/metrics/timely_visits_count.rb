class Metrics::TimelyVisitsCount
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  attr_accessor :date

  def attributes
    { timely: timely, overdue: overdue, date: date }
  end

  def false=(count)
    @overdue = count
  end

  def true=(count)
    @timely = count
  end

  def timely
    @timely || 0
  end

  def overdue
    @overdue || 0
  end
end
