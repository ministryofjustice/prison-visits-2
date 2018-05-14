class ConcreteSlotType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(String)
      ConcreteSlot.parse(value)
    else
      value
    end
  end
end
