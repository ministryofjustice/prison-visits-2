class Cancellation < ActiveRecord::Base
  VISITOR_CANCELLED = 'visitor_cancelled'

  STAFF_REASONS = %w[
    slot_unavailable
    prisoner_moved
  ]

  REASONS = STAFF_REASONS + [VISITOR_CANCELLED]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
end
