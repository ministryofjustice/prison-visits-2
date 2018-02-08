class PrisonType < ActiveModel::Type::Value
  def cast(value)
    value
  end
end
