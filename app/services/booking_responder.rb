class BookingResponder
  delegate :visit, to: :staff_response

  def initialize(visit, user: nil, message: nil, options: {})
    self.staff_response = StaffResponse.new(
      visit: visit,
      user: user,
      validate_visitors_nomis_ready: options[:validate_visitors_nomis_ready])

    self.message = message
    self.persist_to_nomis = options[:persist_to_nomis]
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
    @processor ||= begin
      if bookable?
        BookingResponder::Accept
      else
        BookingResponder::Reject
      end.new(staff_response, processor_opts)
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

  def persist_to_nomis=(val)
    @persist_to_nomis = ActiveRecord::Type::Boolean.new.cast(val)
  end

  def persist_to_nomis?
    !!@persist_to_nomis
  end

  def processor_opts
    { persist_to_nomis: persist_to_nomis? }
  end
end
