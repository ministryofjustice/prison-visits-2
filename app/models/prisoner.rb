class Prisoner < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  has_many :visits, dependent: :destroy
  validates :number, presence: true

  before_validation(on: :create) do
    if attribute_present?('number')
      self.number = self.class.normalise_number(number)
    end
  end

  def self.normalise_number(number)
    number.upcase.strip
  end
end
