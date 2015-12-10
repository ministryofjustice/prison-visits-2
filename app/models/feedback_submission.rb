class FeedbackSubmission < ActiveRecord::Base
  validates :body, presence: true
  validate :validate_email

  def email_address
    super.present? ? super : 'feedback@email.prisonvisits.service.gov.uk'
  end

private

  def validate_email
    return unless email_address.present?
    email_checker = EmailChecker.new(email_address)
    errors.add :email_address, email_checker.message unless email_checker.valid?
  end
end
