class BookingResponder
  delegate :visit, to: :staff_response

  def initialize(staff_response, message: nil)
    self.staff_response   = staff_response
    self.message          = message
  end

  def respond!
    unless staff_response.valid?
      return BookingResponse.process_required
    end

    processor.process_request(message)
  end

private

  attr_accessor :staff_response, :message

  def processor
    @processor ||= if bookable?
                     BookingResponder::Accept
                   else
                     BookingResponder::Reject
                   end.new(staff_response)
  end

  def bookable?
    (visit.rejection.nil? || visit.rejection.invalid?) &&
      visit.slot_granted?
  end
end
