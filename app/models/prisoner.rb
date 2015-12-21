class Prisoner < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  has_many :visits, dependent: :destroy
  validates :number, presence: true
end
