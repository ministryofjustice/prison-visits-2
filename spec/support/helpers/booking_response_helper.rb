module BookingResponseHelper
  def reject_visit(visit, reasons = [Rejection::NO_ALLOWANCE])
    booking_response = BookingResponse.new(visit: visit)
    booking_response.valid?
    booking_response.visit.rejection.reasons += reasons
    BookingResponder.new(booking_response).respond!
  end
end
