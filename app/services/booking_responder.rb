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
  end
end
