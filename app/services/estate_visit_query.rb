class EstateVisitQuery
  def initialize(estates)
    @estates = estates
  end

  def visits_to_print_by_slot(date)
    return {} unless date

    visits = Visit.includes(:prisoner, :visitors).
             processed.from_estates(@estates).
             where('slot_granted LIKE ?', "#{date.to_s(:db)}%").
             order('slot_granted asc').to_a

    visits.
      group_by(&:processing_state).
      each_with_object({}) do |(processing_state, slots), result|
        result[processing_state] = slots.group_by(&:slot_granted)
      end
  end

  def processed(limit:, prisoner_number:)
    visits = Visit.preload(:prisoner, :visitors).
             processed.
             from_estates(@estates).
             order('visits.updated_at desc').limit(limit)

    if prisoner_number.present?
      number = Prisoner.normalise_number(prisoner_number)
      visits = visits.joins(:prisoner).where(prisoners: { number: number })
    end

    visits.to_a
  end

  def inbox_count
    Visit.
      ready_for_processing.
      from_estates(@estates).
      count
  end
end
