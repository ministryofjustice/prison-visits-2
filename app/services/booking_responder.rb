class BookingResponder
  delegate :visit, to: :booking_response

  def initialize(booking_response, message = nil)
    @booking_response = booking_response
    @message = message
  end

  def respond!
    return unless visit.requested?
    processor.process_request(message)

    send_notifications
  end

  def visitor_mailer
    @visitor_mailer ||= VisitorMailer.send(
      email, booking_response.email_attrs, message_attributes
    )
  end

private

  attr_reader :booking_response, :message

  def send_notifications
    visitor_mailer.deliver_later
    prison_mailer.deliver_later
  end

  def processor
    @processor ||= begin
      if bookable?
        BookingResponder::Accept
      else
        BookingResponder::Reject
      end.new(booking_response)
    end
  end

  def prison_mailer
    @prison_mailer ||= PrisonMailer.send(
      email, booking_response.email_attrs, message_attributes
    )
  end

  def email
    @email ||= bookable? ? :booked : :rejected
  end

  def message_attributes
    message && message.attributes.slice('id', 'body')
  end

  def bookable?
    visit.rejection.invalid? && visit.slot_granted?
  end
end
