class Rejection < ActiveRecord::Base
  REASONS = %w[
    slot_unavailable
    no_allowance
    prisoner_details_incorrect
    prisoner_moved
  ]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
end
