class Prisoner < ActiveRecord::Base
  include Person

  has_many :visits
  validates :number, presence: true
end
