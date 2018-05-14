class LevelListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |level| Nomis::HousingLocation::Level.new(level) }.freeze
  end
end
