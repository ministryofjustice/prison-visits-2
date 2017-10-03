class Cancellation < ActiveRecord::Base
  VISITOR_CANCELLED = 'visitor_cancelled'

  STAFF_REASONS = %w[
    booked_in_error
    capacity_issues
    child_protection_issues
    prisoner_moved
    prisoner_non_association
    prisoner_released
    prisoner_vos
    slot_unavailable
    visitor_banned
  ]

  REASONS = STAFF_REASONS + [VISITOR_CANCELLED]

  belongs_to :visit

  validate :validate_reasons
  validates :reasons, presence: true
  validates :reason, inclusion: { in: REASONS }

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
