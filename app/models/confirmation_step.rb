class ConfirmationStep
  include NonPersistedModel

  attribute :confirmed, Boolean
  validates :confirmed, inclusion: { in: [true] }
end
