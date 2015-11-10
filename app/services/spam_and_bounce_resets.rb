class SpamAndBounceResets
  def initialize(visit)
    @visit = visit
  end

  delegate :visitor_email_address, :override_email_checks?, :email_override,
    to: :@visit

  delegate :remove_from_bounce_list, :remove_from_spam_list, to: :SendgridApi

  def perform_resets
    return unless override_email_checks?
    remove_from_bounce_list(visitor_email_address) if reset.bounced?
    remove_from_spam_list(visitor_email_address) if reset.spam_reported?
  end

private

  def reset
    email_override.to_s.inquiry
  end
end
