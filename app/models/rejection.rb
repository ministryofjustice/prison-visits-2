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

  def pvo_possible?
    pvo_expires_on.present?
  end

  def vo_will_be_renewed?
    vo_renewed_on.present?
  end
end
