# frozen_string_literal:true

class SlotDay < ApplicationRecord
  belongs_to :prison, inverse_of: :slot_days
  has_many :slot_times, dependent: :destroy

  validates :day, inclusion: { in: %w[mon tue wed thu fri sat sun], allow_nil: false }
  validates :start_date, presence: true
end
