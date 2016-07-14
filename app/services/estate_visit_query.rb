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
             order('slot_granted asc').
             to_a

    visits.group_by(&:slot_granted)
  end

  def processed(limit:, prisoner_number: nil)
    visits = base_processed_query(limit: limit)

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end

private

  def base_processed_query(limit:)
    Visit.preload(:prisoner, :visitors).
      joins(<<-EOS).
LEFT OUTER JOIN cancellations ON cancellations.visit_id = visits.id
      EOS
      where(<<-EOS, nomis_cancelled: true).
cancellations.id IS NULL OR cancellations.nomis_cancelled = :nomis_cancelled
      EOS
      without_processing_state(:requested).
      from_estate(@estate).
      order('visits.updated_at desc').limit(limit)
  end
end
