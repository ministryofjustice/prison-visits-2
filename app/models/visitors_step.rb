class VisitorsStep
  include NonPersistedModel
  include Person

  attribute :email_address, String
  attribute :override_delivery_error, Boolean
  attribute :delivery_error_type, String
  attribute :delivery_error_occurred, Boolean
  attribute :phone_no, String

  validates :email_address, presence: true
  validates :phone_no, presence: true, length: { minimum: 9 }

  validate :validate_email

private

  def validate_email
    checker = EmailChecker.new(email_address, override_delivery_error)
    unless checker.valid?
      errors.add :email_address, checker.message
      @delivery_error_occurred = checker.delivery_error_occurred?
      @delivery_error_type = checker.error.to_sym
    end
  end
end
