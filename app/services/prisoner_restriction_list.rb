class PrisonerRestrictionList
  def initialize(offender)
    @offender = offender
  end

  def unknown_result?
    !offender_restrictions.api_call_successful
  end

  def on_slot(slot)
    offender_restrictions.
      select(&:closed?).
      select { |restriction| restriction.effective_at?(slot.to_date) }.
      map(&:name)
  end

  def active
    offender_restrictions.
      select { |restriction| restriction.effective_at?(Time.zone.today) }
  end

  def offender_restrictions
    return empty_offender_restrictions unless @offender.valid?

    @offender_restrictions ||= load_offender_restrictions
  end

private

  def load_offender_restrictions
    Nomis::Api.instance.fetch_offender_restrictions(offender_id: @offender.id)
  rescue Nomis::APIError => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    empty_offender_restrictions
  end

  def empty_offender_restrictions
    @empty_offender_restrictions ||=
      Nomis::Offender::Restrictions.new(api_call_successful: false)
  end
end
