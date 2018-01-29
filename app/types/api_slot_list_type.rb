class ApiSlotListType < ActiveModel::Type::Value
  def cast(value)
    api_slots = value.map { |api_slot| Nomis::ApiSlot.new(api_slot) }

    ApiSlotList.new(api_slots)
  end
end
