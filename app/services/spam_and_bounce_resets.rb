class SpamAndBounceResets
  def initialize(visit)
    @visit = visit
  end

  delegate :visitor_email_address, :override_delivery_error?,
    :delivery_error_type, to: :@visit

  delegate :remove_from_bounce_list, :remove_from_spam_list, to: :SendgridApi

  def perform_resets
    return unless override_delivery_error?
    remove_from_bounce_list(visitor_email_address) if delivery_error.bounced?
    remove_from_spam_list(visitor_email_address) if
      delivery_error.spam_reported?
  end

private

  def delivery_error
    delivery_error_type.to_s.inquiry
  end
end
