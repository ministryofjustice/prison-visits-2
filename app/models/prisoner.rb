class Prisoner < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  has_many :visits, dependent: :destroy
  validates :number, presence: true

  before_validation(on: :create) do
    self.number = number.upcase.strip if attribute_present?('number')
  end
end
