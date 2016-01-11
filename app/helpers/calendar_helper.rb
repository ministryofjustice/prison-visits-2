module CalendarHelper
  def each_day_of_week
    first = Time.zone.today.beginning_of_week
    7.times.each do |offset|
      yield(first + offset)
    end
  end

  def today?(day)
    day == Time.zone.today
  end

  def future?(day)
    day > Time.zone.today
  end

  def first_day_of_month?(day)
    day.beginning_of_month == day
  end

  def tagged?(day)
    today?(day) || first_day_of_month?(day)
  end

  def weeks(prison)
    begin_on = Time.zone.today.beginning_of_week
    end_on = prison.last_bookable_date.end_of_month.end_of_week
    (begin_on..end_on).group_by(&:beginning_of_week).values
  end

  def calendar_day(date, bookable)
    day = content_tag(
      :span, I18n.l(date, format: :day_of_month),
      class: 'BookingCalendar-day'
    )
    return day if bookable == false
    content_tag(
      :a, day,
      class: 'BookingCalendar-dateLink', 'data-date': date.iso8601,
      href: "#date-#{date.iso8601}"
    )
  end

  def bookable(prison, day)
    prison.bookable_date?(day) ? 'bookable' : 'unavailable'
  end
end
