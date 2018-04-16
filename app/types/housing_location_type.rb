class HousingLocationType < ActiveModel::Type::Value
  def cast(value)
    Nomis::HousingLocation.new(value)
  end
end
