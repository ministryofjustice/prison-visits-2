class PrisonerContactList
  delegate :approved, to: :contact_list

  def initialize(offender)
    @offender = offender
  end

  def unknown_result?
    contact_list.nil?
  end

private

  def contact_list
    return nil unless @offender.valid?

    @contact_list ||= load_contact_list
  end

  def load_contact_list
    return nil if @api_error

    Nomis::Api.instance.fetch_contact_list(offender_id: @offender.id)
  rescue Nomis::APIError => e
    @api_error = true
    Rails.logger.warn "Error calling the NOMIS API: #{e.inspect}"
    nil
  end
end
