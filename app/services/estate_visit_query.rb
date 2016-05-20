class EstateVisitQuery
  def initialize(estate)
    @estate = estate
  end

  def visits_to_print_by_slot(date)
    return {} unless date

    visits = Visit.
             includes(:prisoner, :visitors).
             with_processing_state(:booked).
             from_estate(@estate).
             where('slot_granted LIKE ?', "#{date.to_s(:db)}%").
             to_a

    visits.group_by(&:slot_granted)
  end
end
