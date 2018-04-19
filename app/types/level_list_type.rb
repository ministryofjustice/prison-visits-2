class LevelListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |level| Nomis::HousingLocation::Level.new(level) }.dup.freeze
  end
end
