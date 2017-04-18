class Visitor < ActiveRecord::Base
  include Person
  extend FreshnessCalculations

  belongs_to :visit

  validate :banned_when_banned_until
  validate :banned_until_is_in_future, if: :banned?

  validates :visit, :sort_index, presence: true
  validate :banned_until_is_a_date

  default_scope do
    order(sort_index: :asc)
  end

  scope :banned,   -> { where(banned: true) }
  scope :unlisted, -> { where(not_on_list: true) }
  scope :allowed,  -> { where(banned: false, not_on_list: false) }

  def banned_until_is_a_date
    if banned_until && !banned_until.is_a?(Date)
      errors.add(:banned_until, :invalid)
    end
  end

  def banned_when_banned_until
    if banned_until && !banned?
      errors.add(:banned, 'Banned must be selected when the banned until date is set')
    end
  end

  def banned_until_is_in_future
    return unless banned_until.is_a?(Date)

    if banned_until_changed? && banned_until <= Date.current
      errors.add(:banned_until, 'Banned until date must be in the future')
    end
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
