class PrisonerStep
  include NonPersistedModel
  include Person

  attribute :number, String
  attribute :prison_id, Integer

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }
  validates :prison_id, presence: true

  def prison
    Prison.find(prison_id)
  end
end
