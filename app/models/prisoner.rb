class Prisoner < ActiveRecord::Base
  include Person

  has_many :visits, dependent: :destroy
  validates :number, presence: true
end
