class CreateNomisVisit
  ALREADY_BOOKED_IN_NOMIS = 'Duplicate post'.freeze
  PVB_USER_ID_HEADER_FIELD = 'PVB-User-id'.freeze

  def initialize(visit, creator:)
    self.visit = visit
    self.api_error = false
    self.creator = creator
  end

  def execute
    call_api
    build_booking_response
  end

  def nomis_visit_id
    booking.visit_id
  end

  def visit_order
    @visit_order ||= begin
                       return unless booking.visit_order
                       visit.build_visit_order(
                         number: booking.visit_order.number,
                         code: booking.visit_order.code,
                         type: vo_type
                       )
                     end
  end

private

  attr_accessor :visit, :booking, :api_error, :creator

  def vo_type
    case booking.visit_order.code
    when Nomis::VisitOrder::VO  then VisitOrder
    when Nomis::VisitOrder::PVO then VisitOrder::Priviledged
    else
      VisitOrder::Unsupported
    end
  end

  def call_api
    booking_params[:headers] = booking_headers
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

  # rubocop:disable Metrics/MethodLength
  def booking_params
    @booking_params ||= {
      lead_contact: visit.principal_visitor.nomis_id,
      other_contacts: visit.allowed_additional_visitors.map(&:nomis_id),
      slot: visit.slot_granted.to_s,
      override_offender_restrictions: false,
      override_visitor_restrictions: false,
      override_vo_balance: false,
      override_slot_capacity: false,
      client_unique_ref: visit.id,
      comment: visit.nomis_comments,
      visit_order_type: visit.visit_order&.code
    }
  end
  # rubocop:enable Metrics/MethodLength

  def booking_headers
    { PVB_USER_ID_HEADER_FIELD => creator.email }
  end
end
