class CancellationResponse
  attr_reader :visit, :user, :reason

  def initialize(visit:, user:, reason:)
    @visit = visit
    @user = user
    @reason = reason
  end

  def can_cancel?
    @visit.can_cancel?
  end

  def cancel!
    processor.process_request
    visitor_mailer.deliver_later
  end

private

  def processor
    @processor ||= BookingResponder::Cancel.new(self)
  end

  def visitor_mailer
    VisitorMailer.cancelled(visit)
  end
end
