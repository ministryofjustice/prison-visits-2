class Visitor < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  scope :banned,   -> { where(banned: true) }
  scope :unlisted, -> { where(not_on_list: true) }
  scope :allowed,  -> { where(banned: false, not_on_list: false) }

  belongs_to :visit
  validates :visit, :sort_index, presence: true

  default_scope do
    order(sort_index: :asc)
  end

  def banned_until?
    banned_until.is_a?(Date)
  end

  def banned_until=(accessible_date)
    date = AccessibleDate.new(accessible_date)
    if date.valid?
      super(date.to_date)
    else
      super(accessible_date)
    end
  rescue
    super DateCoercer.coerce(accessible_date)
  end

  def allowed?
    !(banned || not_on_list)
  end

  def status
    return 'banned' if banned?
    return 'not on list' if not_on_list?
    'allowed'
  end
end
