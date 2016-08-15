class FeedbackSubmission < ActiveRecord::Base
  belongs_to :prison

  validates :body, presence: true
  validate :email_format

  before_validation :strip_email_address, on: :create

private

  def strip_email_address
    self.email_address = email_address.strip
  end

  def email_format
    return if email_address.blank?

    email_checker = EmailChecker.new(email_address)

    unless email_checker.valid?
      errors.add(:email_address, 'has incorrect format')
    end
  end
end
