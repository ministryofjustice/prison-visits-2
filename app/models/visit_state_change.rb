class VisitStateChange < ActiveRecord::Base
  belongs_to :visit

  scope :booked, -> { where(visit_state: 'booked') }
  scope :rejected, -> { where(visit_state: 'rejected') }
  scope :withdrawn, -> { where(visit_state: 'withdrawn') }
  scope :cancelled, -> { where(visit_state: 'cancelled') }
end
