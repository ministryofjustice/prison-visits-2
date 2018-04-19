class ApiSlotListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |api_slot| Nomis::ApiSlot.new(api_slot) }.freeze
  end
end
