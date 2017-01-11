# frozen_string_literal: true
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

private

  # Returns a nested hash like:
  # { 'Cardiff' => { 'booked' => { concrete_slot1 => [ v1, v2] }}}
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
end
