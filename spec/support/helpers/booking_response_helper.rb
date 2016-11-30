module BookingResponseHelper
  def accept_visit(visit, slot)
    visit.slot_granted = slot
    BookingResponder::Accept.new(
      BookingResponse.new(visit: visit)
    ).process_request
    visit
  end

  def cancel_visit(visit, reason = Cancellation::VISITOR_CANCELLED)
    accept_visit(visit, visit.slots.first)
    CancellationResponse.new(
      visit:  visit,
      user:   create(:user),
      reason: reason
    ).cancel!
    visit
  end

  def reject_visit(visit, reasons = [Rejection::SLOT_UNAVAILABLE])
    booking_response = BookingResponse.new(visit: visit)
    booking_response.valid?
    booking_response.visit.rejection.reasons += reasons
    BookingResponder.new(booking_response).respond!
  end

  def withdraw_visit(visit)
    VisitorWithdrawalResponse.new(visit: visit).withdraw!
  end
end
