class PrisonerDateAvailabilityListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |date| Nomis::PrisonerDateAvailability.new(date) }.freeze
  end
end
