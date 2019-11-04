# frozen_string_literal: true

class UnbookableDate < ApplicationRecord
  belongs_to :prison, inverse_of: :unbookable_dates

  validate :date_must_be_in_the_future

  validates :date, presence: true, uniqueness: { scope: :prison_id }

  acts_as_gov_uk_date :date

private

  def date_must_be_in_the_future
    if date.present? && date <= Time.zone.today
      errors.add(:date, :unbookable_date_in_the_past)
    end
  end
end
