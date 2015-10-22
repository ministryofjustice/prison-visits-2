class PrisonerStep
  include NonPersistedModel
  include Person

  attribute :number, String
  attribute :prison_name, String

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }
end
