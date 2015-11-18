class Rejection < ActiveRecord::Base
  REASONS = %w[
    slot_unavailable
    no_allowance
  ]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
end
