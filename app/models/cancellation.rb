class Cancellation < ActiveRecord::Base
  VISITOR_CANCELLED = 'visitor_cancelled'.freeze
  CHILD_PROTECTION_ISSUES = 'child_protection_issues'.freeze
  PRISONER_NON_ASSOCIATION = 'prisoner_non_association'.freeze
  VISITOR_BANNED = 'visitor_banned'.freeze

  STAFF_REASONS = [
    'booked_in_error',
    'capacity_issues',
    CHILD_PROTECTION_ISSUES,
    'prisoner_moved',
    PRISONER_NON_ASSOCIATION,
    'prisoner_released',
    'prisoner_vos',
    'slot_unavailable',
    VISITOR_BANNED
  ]

  REASONS = STAFF_REASONS + [VISITOR_CANCELLED]

  belongs_to :visit

  validate :validate_reasons
  validates :reasons, presence: true

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
end
