class PrisonerRestrictionList
  def initialize(offender)
    @offender = offender
  end

  def on_slot(slot)
    offender_restrictions.
      select(&:closed?).
      select { |restriction| restriction.effective?(slot.to_date) }.
      map(&:name)
  end

private

  def offender_restrictions
    return empty_offender_restrictions unless @offender.valid?

    @offender_restrictions ||= load_offender_restrictions
  end

  def load_offender_restrictions
    Nomis::Api.instance.fetch_offender_restrictions(offender_id: @offender.id)
  rescue Nomis::APIError => e
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    empty_offender_restrictions
  end

  def empty_offender_restrictions
    @empty_offender_restrictions ||=
      Nomis::OffenderRestrictions.new(api_call_successful: false)
  end
end
