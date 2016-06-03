class Cancellation < ActiveRecord::Base
  REASONS = %w[
    slot_unavailable
    prisoner_moved
  ]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
end
