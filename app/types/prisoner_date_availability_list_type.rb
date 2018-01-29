class PrisonerDateAvailabilityListType < ActiveModel::Type::Value
  def cast(value)
    dates = value.map { |date| Nomis::PrisonerDateAvailability.new(date) }

    PrisonerDateAvailabilityList.new(dates)
  end
end
