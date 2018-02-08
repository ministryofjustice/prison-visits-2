class AvailabilityVisitListType < ActiveModel::Type::Value
  def cast(value)
    visits = value.map { |visit| Nomis::AvailabilityVisit.new(visit) }

    AvailabilityVisitList.new(visits)
  end
end
