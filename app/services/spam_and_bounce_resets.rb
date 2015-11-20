class SpamAndBounceResets
  def initialize(visit)
    @visit = visit
  end

  delegate :visitor_email_address, :override_spam_or_bounce?, :spam_or_bounce,
    to: :@visit

  delegate :remove_from_bounce_list, :remove_from_spam_list, to: :SendgridApi

  def perform_resets
    return unless override_spam_or_bounce?
    remove_from_bounce_list(visitor_email_address) if reset.bounced?
    remove_from_spam_list(visitor_email_address) if reset.spam_reported?
  end

private

  def reset
    spam_or_bounce.to_s.inquiry
  end
end
