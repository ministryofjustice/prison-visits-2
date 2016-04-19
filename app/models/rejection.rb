class Rejection < ActiveRecord::Base
  REASONS = %w[
    slot_unavailable
    no_adult
    no_allowance
    prisoner_details_incorrect
    prisoner_moved
    visitor_banned
    visitor_not_on_list
  ]

  belongs_to :visit

  validates :reason, inclusion: { in: REASONS }

  def privileged_allowance_available?
    privileged_allowance_expires_on.present?
  end

  def allowance_will_renew?
    allowance_renews_on.present?
  end
end
