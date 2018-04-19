class AvailabilityVisitListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |visit| Nomis::AvailabilityVisit.new(visit) }.dup.freeze
  end
end
