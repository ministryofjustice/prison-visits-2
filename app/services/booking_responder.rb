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
  end

  def reject!
    visit.reject!
    rejection = Rejection.new(visit: visit)
    copy_no_allowance_parameters rejection if booking_response.no_allowance?
    rejection.save!
  end

  def copy_no_allowance_parameters(rejection)
    if booking_response.vo_will_be_renewed?
      rejection.vo_renewed_on = booking_response.vo_renewed_on
    end

    if booking_response.pvo_possible?
      rejection.pvo_expires_on = booking_response.pvo_expires_on
    end
  end
end
