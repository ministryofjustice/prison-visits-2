class EstateVisitQuery
  def initialize(estates)
    @estates = estates
  end

  def visits_to_print_by_slot(date)
    return {} unless date

    visits = Visit.includes(:prisoner, :visitors, :prison).
             processed.from_estates(@estates).
             where('slot_granted LIKE ?', "#{date.to_s(:db)}%").
             order('slot_granted asc').to_a

    grouped_visits(visits)
  end

  def processed(limit:, query:)
    visits = Visit.
             less_than_six_months_old.
             preload(:prisoner, :visitors, :prison).
             processed.
             from_estates(@estates).
             order('visits.updated_at desc').limit(limit)

    visits = search(visits, query) if query
    visits.to_a
  end

  def requested(query: nil)
    visits = Visit.
             preload(:prisoner, :visitors, :prison).
             with_processing_state(:requested).
             from_estates(@estates).
             order('created_at asc')
    if query
      visits = search(visits.less_than_six_months_old, query)
    end
    visits.to_a
  end

  def cancelled(query: nil)
    visits = Visit.
             preload(:prisoner, :visitors, :cancellation, :prison).
             joins(:cancellation).
             from_estates(@estates).
             where(cancellations: { nomis_cancelled: false }).
             order('created_at asc')

    if query
      visits = search(visits.less_than_six_months_old, query)
    end
    visits.to_a
  end

  def inbox_count
    Visit.
      ready_for_processing.
      from_estates(@estates).
      count
  end

private

  # Returns a nested hash like:
  # { 'Cardiff' => { 'booked' => { concrete_slot1 => [v1, v2] }}}
  def grouped_visits(visits)
    visits.
      group_by(&:prison_name).
      each_with_object({}) do |(prison_name, visits_by_prison), result|
        result[prison_name] = {}

        by_processing_state = visits_by_prison.group_by(&:processing_state)
        by_processing_state.each do |processing_state, visits_by_status|
          result[prison_name][processing_state] = visits_by_status.
                                                  group_by(&:slot_granted)
        end
      end
  end

  def search(visits, query)
    normalised = query.upcase.strip
    # TODO: Can be rewritten when we are on Rails 5
    # Not yet, there is an open Rails issue that prevents this: #24055
    visits.
      joins(:prisoner).
      where('prisoners.number = :value OR visits.human_id = :value', value: normalised)
  end
end
