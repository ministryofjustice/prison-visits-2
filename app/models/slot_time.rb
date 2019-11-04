# frozen_string_literal:true

class SlotTime < ApplicationRecord
  belongs_to :slot_day

  validates :begin_hour, :end_hour, inclusion: { in: (0..23), allow_nil: false }
  validates :begin_minute, :end_minute, inclusion: { in: (0..59), allow_nil: false }

  validate :ends_after_begins

private

  def ends_after_begins
    unless (end_hour * 60 + end_minute) > (begin_hour * 60 + begin_minute)
      errors.add(:base, :start_time_after_end_time)
    end
  end
end
