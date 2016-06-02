class Visitor < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  belongs_to :visit
  validates :visit, :sort_index, presence: true

  default_scope do
    order(sort_index: :asc)
  end

  def allowed?
    !(banned || not_on_list)
  end

  def self.allowed
    where(banned: false, not_on_list: false)
  end

  def self.banned
    where(banned: true)
  end

  def self.unlisted
    where(not_on_list: true)
  end
end
