class VisitorsStep
  include NonPersistedModel
  include Person

  attribute :email_address, String
  attribute :phone_no, String

  validates :email_address, presence: true
  validates :phone_no, presence: true, length: { minimum: 9 }
end
