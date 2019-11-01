# frozen_string_literal:true

class SlotTime < ApplicationRecord
  belongs_to :slot_day

  validates :start_hour, :end_hour, inclusion: { in: (0..23), allow_nil: false }
  validates :start_minute, :end_minute, inclusion: { in: (0..59), allow_nil: false }
end
