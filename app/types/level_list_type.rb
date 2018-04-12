class LevelListType < ActiveModel::Type::Value

  def cast(value)
    levels = value.map { |visitor| VisitorType.new.cast(levels) }

    LevelList.new(levels)
  end


end
