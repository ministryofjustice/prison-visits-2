class PrisonerStep
  include NonPersistedModel
  include Person

  attribute :first_name, String
  attribute :last_name, String
  attribute :date_of_birth, Date
  attribute :number, String
  attribute :prison_id, Integer

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }
  validates :prison_id, presence: true

  delegate :name, to: :prison, prefix: true

  def prison
    Prison.find_by(id: prison_id)
  end
end
