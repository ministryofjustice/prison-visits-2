class DayDecorator < Draper::Decorator
  delegate_all

  DECORATED_DAYS = decorate_collection(%w[mon tue wed thu fri sat sun])

  def to_partial_path
    'days/day'
  end
end
