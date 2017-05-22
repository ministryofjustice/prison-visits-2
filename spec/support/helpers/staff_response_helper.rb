module StaffResponseHelper
  def accept_visit(visit, slot)
    visit.slot_granted = slot
    BookingResponder::Accept.new(
      StaffResponse.new(visit: visit)
    ).process_request
    visit
  end

  def cancel_visit(visit, reason = Cancellation::VISITOR_CANCELLED)
    accept_visit(visit, visit.slots.first)
    CancellationResponse.new(
      visit: visit,
      user:   create(:user),
      reason: reason
    ).cancel!
    visit
  end

  def reject_visit(visit, reasons = [Rejection::SLOT_UNAVAILABLE])
    visit.rejection || visit.build_rejection
    visit.rejection.reasons += reasons
    BookingResponder.new(visit).respond!
  end

  def withdraw_visit(visit)
    VisitorWithdrawalResponse.new(visit: visit).withdraw!
  end
end
