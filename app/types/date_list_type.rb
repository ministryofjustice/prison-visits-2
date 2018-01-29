class DateListType < ActiveModel::Type::Value
  def cast(value)
    dates = value.map { |date| Date.parse(date) }

    DateList.new(dates)
  end
end
