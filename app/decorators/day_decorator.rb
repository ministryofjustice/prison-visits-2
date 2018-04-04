class DayDecorator < Draper::Decorator
  delegate_all
  def to_partial_path
    'days/day'
  end
end
