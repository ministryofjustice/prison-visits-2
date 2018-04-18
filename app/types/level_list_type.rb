require 'typed_list/level_list'

class LevelListType < ActiveModel::Type::Value
  def cast(value)
    levels = value.map { |level| Nomis::HousingLocation::Level.new(level) }
    LevelList.new(levels)
  end
end
