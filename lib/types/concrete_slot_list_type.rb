class ConcreteSlotListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |slot| ConcreteSlotType.new.cast(slot) }.freeze
  end
end
