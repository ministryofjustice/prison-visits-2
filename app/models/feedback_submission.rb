require 'email_address_validation'

class FeedbackSubmission < ApplicationRecord
  belongs_to :prison

  validates :body, presence: true
  validates :prisoner_date_of_birth, allow_blank: true, age: true
  validates :prisoner_number, allow_blank: true, prisoner_number: true
  validate :email_format

  before_validation :strip_email_address, on: :create

private

  def strip_email_address
    self.email_address = email_address&.strip
  end

  def email_format
    return if email_address.blank?

    email_checker = EmailAddressValidation::Checker.new(email_address)

    unless email_checker.valid?
      errors.add(:email_address, 'has incorrect format')
    end
  end
end
