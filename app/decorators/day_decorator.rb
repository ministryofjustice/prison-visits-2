class DayDecorator < Draper::Decorator
  delegate_all

  DAYS_OF_THE_WEEK = %w[mon tue wed thu fri sat sun].freeze

  DECORATED_DAYS = decorate_collection(DAYS_OF_THE_WEEK)

  def to_partial_path
    'days/day'
  end
end
