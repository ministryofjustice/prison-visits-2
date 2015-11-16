class BookingResponder
  def initialize(booking_response)
    @booking_response = booking_response
  end

  def respond!
    case booking_response.selection
    when /\Aslot_(\d+)\z/
      accept!
    end
  end

private

  attr_reader :booking_response
  delegate :visit, to: :booking_response

  def accept!
    visit.accept!
  end
end
