class SpamAndBounceResets
  def initialize(visitor)
    @visitor = visitor
  end

  delegate :email, :override_email_checks?, :email_override, to: :@visitor

  delegate :remove_from_bounce_list, :remove_from_spam_list, to: :SendgridApi

  def perform_resets
    return unless override_email_checks?
    remove_from_bounce_list(email) if reset.bounced?
    remove_from_spam_list(email) if reset.spam_reported?
  end

private

  def reset
    email_override.inquiry
  end
end
