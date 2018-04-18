require 'typed_list/concrete_slot_list'

class ConcreteSlotListType < ActiveModel::Type::Value
  def cast(value)
    slots = value.map { |slot| ConcreteSlotType.new.cast(slot) }

    ConcreteSlotList.new(slots)
  end
end
