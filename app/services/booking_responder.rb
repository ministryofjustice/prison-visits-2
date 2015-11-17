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
    visit.slot_granted = visit.slots.fetch(booking_response.slot_index)
    visit.reference_no = booking_response.reference_no
    visit.accept
    visit.save!
  end

  def reject!
    visit.reject!
  end
end
