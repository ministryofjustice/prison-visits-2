class PrisonerDateAvailabilityListType < ActiveModel::Type::Value
  def cast(value)
    value.map { |date| Nomis::Offender::DateAvailability.new(date) }.freeze
  end
end
