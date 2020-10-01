class DayDecorator < Draper::Decorator
  delegate_all

  DECORATED_DAYS = decorate_collection(SlotInfoHelper::DAYS_OF_THE_WEEK)

  def to_partial_path
    'days/day'
  end
end
