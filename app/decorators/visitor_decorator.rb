# frozen_string_literal: true
class VisitorDecorator < Draper::Decorator
  delegate_all

  def banned_until
    @banned_until ||=
      begin
        if object.banned_until
          AccessibleDate.new(
            date_to_accessible_date(object.banned_until)
          )
        else
          AccessibleDate.new
        end
      end
  end

private

  def date_to_accessible_date(date)
    return date if date.is_a?(Hash)
    {
      year:  date.year,
      month: date.month,
      day:   date.day
    }
  end
end
