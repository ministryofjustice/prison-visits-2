# frozen_string_literal: true
module BookingResponseHelper
  def reject_visit(visit, reasons = [Rejection::SLOT_UNAVAILABLE])
    booking_response = BookingResponse.new(visit: visit)
    booking_response.valid?
    booking_response.visit.rejection.reasons += reasons
    BookingResponder.new(booking_response).respond!
  end
end
