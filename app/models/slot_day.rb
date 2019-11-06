# frozen_string_literal:true

class SlotDay < ApplicationRecord
  DAYS_OF_THE_WEEK = %w[mon tue wed thu fri sat sun].freeze

  belongs_to :prison, inverse_of: :slot_days
  has_many :slot_times, dependent: :destroy

  validates :day, inclusion: { in: DAYS_OF_THE_WEEK, allow_nil: false }
  validates :start_date, presence: true

  acts_as_gov_uk_date :start_date, :end_date

  def contains?(today)
    start_date <= today && (end_date.nil? || today <= end_date)
  end
end
