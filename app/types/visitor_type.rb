class VisitorType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(Visitor)
      value
    else
      value = value.with_indifferent_access
      accessible_date = AccessibleDateType.new.cast(value[:date_of_birth])
      value[:date_of_birth] = accessible_date&.to_date
      Visitor.new(value)
    end
  end
end
