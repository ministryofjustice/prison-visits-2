class RestrictionTypeType < ActiveModel::Type::Value
  def cast(value)
    Nomis::Restriction::Type.new(value)
  end
end
