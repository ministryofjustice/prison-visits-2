class BookingResponder
  delegate :visit, to: :staff_response

  def initialize(staff_response, message = nil)
    @staff_response = staff_response
    @message = message
  end

  def respond!
    return unless visit.requested?
    processor.process_request(message)

    send_notifications
  end

  def visitor_mailer
    @visitor_mailer ||= VisitorMailer.send(
      email, staff_response.email_attrs, message_attributes
    )
  end

private

  attr_reader :staff_response, :message

  def send_notifications
    visitor_mailer.deliver_later
  end

  def processor
    @processor ||= begin
      if bookable?
        BookingResponder::Accept
      else
        BookingResponder::Reject
      end.new(staff_response)
    end
  end

  def email
    @email ||= bookable? ? :booked : :rejected
  end

  def message_attributes
    message && message.attributes.slice('id', 'body')
  end

  def bookable?
    (visit.rejection.nil? || visit.rejection.invalid?) &&
      visit.slot_granted?
  end
end
