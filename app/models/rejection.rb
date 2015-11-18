class Rejection < ActiveRecord::Base
  REASONS = %w[
    slot_unavailable
    no_allowance
    prisoner_details_incorrect
    prisoner_moved
    visitor_banned
    visitor_not_on_list
  ]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }
end
