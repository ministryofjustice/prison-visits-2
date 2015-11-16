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

  def accept!
    visit.accept!
  end

  def reject!
    visit.reject!
  end
end
