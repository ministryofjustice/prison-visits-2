class CancellationResponse
  include PersistToNomisResponse

  attr_reader :visit, :user
  alias :creator :user

  def initialize(visit, cancellation_attributes, user: nil, persist_to_nomis: false)
    self.visit                   = visit
    self.cancellation_attributes = cancellation_attributes
    self.user                    = user
    super(persist_to_nomis)
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
    @cancellation ||= begin
      cancellation_attributes[:nomis_cancelled] = true
      visit.build_cancellation(cancellation_attributes)
    end
  end
  alias :build_cancellation :cancellation

  def processor
    @processor ||= BookingResponder::Cancel.new(self, processor_options)
  end

  def visitor_mailer
    VisitorMailer.cancelled(visit)
  end

  def processor_options
    { persist_to_nomis: persist_to_nomis? }
  end
end
