# frozen_string_literal: true
require 'maybe_date'

class PrisonerStep
  include NonPersistedModel
  include Person
  include ActiveModel::Validations::Callbacks

  attribute :first_name, String
  attribute :last_name, String
  attribute :date_of_birth, MaybeDate
  attribute :number, String
  attribute :prison_id, Integer

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
