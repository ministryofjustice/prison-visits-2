class VisitorListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |visitor| VisitorType.new.cast(visitor) }.dup.freeze
  end
end
