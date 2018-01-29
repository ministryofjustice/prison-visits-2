class RestrictionType < ActiveModel::Type::Value
  def cast(value)
    if value.is_a?(Nomis::Restriction)
      value
    else
      Nomis::Restriction.new(value)
    end
  end
end
