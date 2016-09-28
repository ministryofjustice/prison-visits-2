class Visitor < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  scope :banned,   -> { where(banned: true) }
  scope :unlisted, -> { where(not_on_list: true) }

  belongs_to :visit
  validates :visit, :sort_index, presence: true

  default_scope do
    order(sort_index: :asc)
  end

  def allowed?
    !(banned || not_on_list)
  end

  def status
    return 'banned' if banned?
    return 'not on list' if not_on_list?
    'allowed'
  end

  def self.allowed
    where(banned: false, not_on_list: false)
  end
end
