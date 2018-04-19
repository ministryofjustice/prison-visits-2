class RestrictionListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |restriction| RestrictionType.new.cast(restriction) }.dup.freeze
  end
end
