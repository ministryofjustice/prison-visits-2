class CancellationResponse
  attr_reader :visit, :user
  alias_method :creator, :user

  def initialize(visit, cancellation_attributes, user: nil)
    self.visit                   = visit
    self.cancellation_attributes = cancellation_attributes
    self.user                    = user
  end

  def valid?
    cancellation.valid?
  end

  def error_message
    cancellation.errors[:reasons].first
  end

  def cancel!
    build_cancellation
    processor.process_request
    visitor_mailer.deliver_later
  end

private

  attr_accessor :cancellation_attributes
  attr_writer :visit, :user

  def cancellation
    @cancellation ||= visit.build_cancellation(cancellation_attributes)
  end
  alias_method :build_cancellation, :cancellation

  def processor
    @processor ||= BookingResponder::Cancel.new(self)
  end

  def visitor_mailer
    VisitorMailer.cancelled(visit)
  end
end
