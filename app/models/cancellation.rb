class Cancellation < ApplicationRecord
  VISITOR_CANCELLED = 'visitor_cancelled'.freeze

  PRISONER_VOS             = 'prisoner_vos'.freeze
  PRISONER_RELEASED        = 'prisoner_released'.freeze
  CHILD_PROTECTION_ISSUES  = 'child_protection_issues'.freeze
  SLOT_UNAVAILABLE         = 'slot_unavailable'.freeze
  VISITOR_BANNED           = 'visitor_banned'.freeze
  PRISONER_MOVED           = 'prisoner_moved'.freeze
  PRISONER_NON_ASSOCIATION = 'prisoner_non_association'.freeze
  PRISONER_CANCELLED       = 'prisoner_cancelled'.freeze
  BOOKED_IN_ERROR          = 'booked_in_error'.freeze
  CAPACITY_ISSUES          = 'capacity_issues'.freeze

  STAFF_REASONS = [
    PRISONER_VOS,
    PRISONER_RELEASED,
    CHILD_PROTECTION_ISSUES,
    SLOT_UNAVAILABLE,
    VISITOR_BANNED,
    PRISONER_MOVED,
    PRISONER_NON_ASSOCIATION,
    PRISONER_CANCELLED,
    BOOKED_IN_ERROR,
    CAPACITY_ISSUES
  ]

  REASONS = STAFF_REASONS + [VISITOR_CANCELLED]

  belongs_to :visit

  before_validation :sanitise_reasons

  validate :validate_reasons
  validates :reasons, presence: { message: :no_cancellation_reason }

private

  def validate_reasons
    reasons.each do |r|
      next if REASONS.include?(r)

      errors.add(
        :reasons,
        I18n.t(
          'activerecord.errors.models.cancellation.invalid_reason',
          reason: r
        )
      )
    end
  end

  def sanitise_reasons
    reasons.reject!(&:empty?)
  end
end
