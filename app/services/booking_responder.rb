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

    booking_response = processor.process_request(message)

    send_notifications if booking_response.success?
    booking_response
  end

  def visitor_mailer
    @visitor_mailer ||= VisitorMailer.send(
      email, staff_response.email_attrs, message_attributes
    )
  end

private

  attr_accessor :staff_response, :message

  def send_notifications
    visitor_mailer.deliver_later
  end

  def processor
    @processor ||= if bookable?
        BookingResponder::Accept
                   else
        BookingResponder::Reject
      end.new(staff_response)
    
  end

  def email
    @email ||= bookable? ? :booked : :rejected
  end

  def message_attributes
    message&.attributes&.slice('id', 'body')
  end

  def bookable?
    (visit.rejection.nil? || visit.rejection.invalid?) &&
      visit.slot_granted?
  end
end
