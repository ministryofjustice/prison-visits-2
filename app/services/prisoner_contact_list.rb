class PrisonerContactList
  delegate :approved, to: :contact_list

  def initialize(prisoner)
    @prisoner = prisoner
  end

  def unknown_result?
    !contact_list.api_call_successful
  end

private

  def contact_list
    return empty_contact_list unless @prisoner.valid?

    @contact_list ||= load_contact_list
  end

  def load_contact_list
    return nil if @api_error

    Nomis::Api.instance.fetch_contact_list(offender_id: @prisoner.nomis_offender_id)
  rescue Nomis::APIError => e
    @api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    empty_contact_list
  end

  def empty_contact_list
    @empty_contact_list ||= Nomis::ContactList.new(api_call_successful: false)
  end
end
