class VisitorWithdrawalResponse
  attr_reader :visit

  def initialize(visit:)
    @visit = visit
  end

  def visitor_can_withdraw?
    visit.can_withdraw?
  end

  def withdraw!
    processor.process_request
  end

  def creator
    visit.principal_visitor
  end

private

  def processor
    @processor ||= BookingResponder::VisitorWithdrawal.new(self)
  end
end
