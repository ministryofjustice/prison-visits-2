class VisitorListType < ActiveModel::Type::Value
  def cast(value)
    visitors = value.map { |visitor| VisitorType.new.cast(visitor) }

    VisitorList.new(visitors)
  end
end
