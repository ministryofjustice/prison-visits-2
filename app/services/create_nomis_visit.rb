class CreateNomisVisit
  ALREADY_BOOKED_IN_NOMIS = 'Duplicate post'.freeze

  def initialize(visit)
    self.visit = visit
    self.api_error = false
  end

  def execute
    call_api
    build_booking_response
  end

  def nomis_visit_id
    booking.visit_id
  end

private

  attr_accessor :visit, :booking, :api_error

  def call_api
    self.booking = Nomis::Api.
      instance.
      book_visit(offender_id: offender_id, params: booking_params)
  rescue Nomis::APIError
    self.api_error = true
  end

  def build_booking_response
    return BookingResponse.nomis_api_error if api_error
    return BookingResponse.successful if booking.visit_id
    return BookingResponse.already_booked_in_nomis if already_booked_in_nomis?
    BookingResponse.nomis_validation_error
  end

  def already_booked_in_nomis?
    booking.error_messages.include?(ALREADY_BOOKED_IN_NOMIS)
  end

  def offender_id
    visit.prisoner.nomis_offender_id
  end

  def booking_params
    {
      lead_contact: visit.principal_visitor.nomis_id,
      other_contacts: visit.allowed_additional_visitors.map(&:nomis_id),
      slot: visit.slot_granted.to_s,
      override_restrictions: false,
      client_unique_ref: visit.id
    }
  end
end
