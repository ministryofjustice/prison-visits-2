class BookingResponder
  def initialize(booking_response)
    @booking_response = booking_response
  end

  def respond!
    if booking_response.slot_selected?
      accept!
    else
      reject!
    end
    LoggerMetadata.add booking_response: visit.processing_state
  end

private

  attr_reader :booking_response
  delegate :visit, to: :booking_response
  private :visit

  def accept!
    visit.accept
    visit.update!(
      slot_granted: visit.slots.fetch(booking_response.slot_index),
      reference_no: booking_response.reference_no,
      closed: booking_response.closed_visit
    )
    notify_accepted visit
  end

  def reject!
    visit.reject!
    rejection = Rejection.new(visit: visit, reason: booking_response.selection)
    copy_no_allowance_parameters rejection if booking_response.no_allowance?
    rejection.save!
    notify_rejected visit
  end

  def copy_no_allowance_parameters(rejection)
    if booking_response.allowance_will_renew?
      rejection.allowance_renews_on = booking_response.allowance_renews_on
    end

    if booking_response.privileged_allowance_available?
      rejection.privileged_allowance_expires_on =
        booking_response.privileged_allowance_expires_on
    end
  end

  def notify_accepted(visit)
    VisitorMailer.booked(visit).deliver_later
    PrisonMailer.booked(visit).deliver_later
  end

  def notify_rejected(visit)
    VisitorMailer.rejected(visit).deliver_later
    PrisonMailer.rejected(visit).deliver_later
  end
end
