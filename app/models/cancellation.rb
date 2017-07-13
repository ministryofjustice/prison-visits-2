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

  validates :reason, inclusion: { in: REASONS }
end
