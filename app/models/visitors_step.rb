class VisitorsStep
  include NonPersistedModel
  include Person

  attribute :email_address, String
  attribute :override_spam_or_bounce, Boolean
  attribute :spam_or_bounce, String
  attribute :spam_or_bounce_has_occurred, Boolean
  attribute :phone_no, String

  validates :email_address, presence: true
  validates :phone_no, presence: true, length: { minimum: 9 }

  validate :validate_email

private

  def validate_email
    checker = EmailChecker.new(email_address, override_spam_or_bounce)
    unless checker.valid?
      errors.add :email_address, checker.message
      @spam_or_bounce_has_occurred = checker.spam_or_bounce_occurred?
      @spam_or_bounce = checker.error
    end
  end
end
