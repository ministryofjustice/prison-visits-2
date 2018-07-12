class PrisonerRestrictionList
  def initialize(prisoner)
    @prisoner = prisoner
  end

  def unknown_result?
    !prisoner_restrictions.api_call_successful
  end

  def on_slot(slot)
    prisoner_restrictions.
      select(&:closed?).
      select { |restriction| restriction.effective_at?(slot.to_date) }.
      map(&:name)
  end

  def active
    prisoner_restrictions.
      select { |restriction| restriction.effective_at?(Time.zone.today) }
  end

  def prisoner_restrictions
    return empty_prisoner_restrictions unless @prisoner.valid?

    @prisoner_restrictions ||= load_prisoner_restrictions
  end

private

  def load_prisoner_restrictions
    Nomis::Api.instance.
      fetch_prisoner_restrictions(offender_id: @prisoner.nomis_offender_id)
  rescue Nomis::APIError => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    empty_prisoner_restrictions
  end

  def empty_prisoner_restrictions
    @empty_prisoner_restrictions ||=
      Nomis::PrisonerRestrictions.new(api_call_successful: false)
  end
end
