class PrisonerStep
  include MemoryModel
  include Person
  include ActiveModel::Validations::Callbacks

  attribute :first_name, :string
  attribute :last_name, :string
  attribute :date_of_birth, :accessible_date
  attribute :number, :string
  attribute :prison_id, :string

  before_validation :scrub_trailing_spaces

  validates :number, format: {
    with: /\A[a-z]\d{4}[a-z]{2}\z/i
  }
  validates :prison_id, presence: true

  delegate :name, to: :prison, prefix: true

private

  def scrub_trailing_spaces
    number.try(:strip!)
  end
end
