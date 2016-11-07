class VisitorCancellationResponse
  attr_reader :visit

  def initialize(visit:)
    @visit = visit
  end

  def visitor_can_cancel?
    visit.can_cancel? && (visit.slot_granted.begin_at >= Time.now.utc)
  end

  def cancel!
    processor.process_request
    prison_mailer.deliver_later
  end

  def visitor
    visit.principal_visitor
  end

private

  def processor
    @processor ||= BookingResponder::VisitorCancel.new(self)
  end

  def prison_mailer
    PrisonMailer.cancelled(visit)
  end
end
