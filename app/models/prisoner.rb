class Prisoner < ApplicationRecord
  include Person
  extend FreshnessCalculations

  attribute :number, :prisoner_number

  has_many :visits, dependent: :destroy
  validates :number, presence: true
end
