module StaffResponseHelper
  def accept_visit(visit, slot)
    visit.slot_granted = slot
    BookingResponder::Accept.new(staff_response_for(visit)).process_request
    visit
  end

  def cancel_visit(visit, reasons = [Cancellation::VISITOR_CANCELLED])
    accept_visit(visit, visit.slots.first)
    CancellationResponse.new(
      visit,
      { reasons: },
      user:   create(:user)
    ).cancel!
    visit
  end

  def reject_visit(visit, reasons = [Rejection::SLOT_UNAVAILABLE])
    visit.rejection || visit.build_rejection
    visit.rejection.reasons += reasons
    BookingResponder.new(staff_response_for(visit)).respond!
  end

  def withdraw_visit(visit)
    VisitorWithdrawalResponse.new(visit:).withdraw!
  end

  def staff_response_for(visit)
    StaffResponse.new(visit:)
  end
end
