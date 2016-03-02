class FeedbackSubmission < ActiveRecord::Base
  validates :body, presence: true
  validate :validate_email

  before_validation :strip_email_address, on: :create

private

  def strip_email_address
    self.email_address = email_address.strip
  end

  def validate_email
    return unless email_address.present?
    email_checker = EmailChecker.new(email_address)
    errors.add :email_address, email_checker.message unless email_checker.valid?
  end
end
