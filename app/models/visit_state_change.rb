class VisitStateChange < ApplicationRecord
  belongs_to :visit
  belongs_to :visitor
  belongs_to :processed_by, class_name: 'User'

  scope :booked, -> { where(visit_state: 'booked') }
  scope :rejected, -> { where(visit_state: 'rejected') }
  scope :withdrawn, -> { where(visit_state: 'withdrawn') }
  scope :cancelled, -> { where(visit_state: 'cancelled') }

  def actioned_by
    visitor || processed_by
  end
end
