class DateListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |date| Date.parse(date) }
  end
end
