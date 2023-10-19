class VisitorCancellationResponse
  attr_reader :visit

  def initialize(visit:)
    @visit = visit
  end

  def visitor_can_cancel?
    visit.can_cancel? && (visit.slot_granted.begin_at >= Time.zone.now.utc)
  end

  def cancel!
    processor.process_request
  end

  def creator
    visit.principal_visitor
  end

private

  def processor
    @processor ||= BookingResponder::VisitorCancel.new(self)
  end
end
