class BookingResponder
  delegate :visit, :bookable?, to: :booking_response

  def initialize(booking_response)
    @booking_response = booking_response
  end

  def respond!
    return unless visit.requested?
    processor.process_request

    send_notifications
  end

  def visitor_mailer
    @visitor_mailer ||= VisitorMailer.send(
      email, booking_response.email_attrs
    )
  end

private

  attr_reader :booking_response

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
      email, booking_response.email_attrs
    )
  end

  def email
    @email ||= bookable? ? :booked : :rejected
  end
end
