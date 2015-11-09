module DateHelper
  def format_date_of_birth(date)
    I18n.l(date.to_date, format: :date_of_birth)
  end

  def format_date_of_visit(date)
    I18n.l(date.to_date, format: :date_of_visit)
  end

  alias_method :format_date_of_visit, :format_date
  alias_method :format_date_of_reply, :format_date

  def format_time_12hr(time)
    I18n.l(time_from_string(time), format: :twelve_hour)
  end

  def format_time_24hr(time)
    I18n.l(time_from_string(time), format: :twenty_four_hour)
  end

  def date_and_duration_of_slot(slot)
    "#{format_date(slot.date)} #{slot_and_duration(slot.times)}"
  end

  def date_and_times_of_slot(slot)
    "#{format_date(slot.date)} #{start_and_end_time(slot.times)}"
  end

  private

  def date_from_string_or_date(obj)
    if obj.is_a?(String)
      Date.parse(obj)
    else
      obj
    end
  end

  def time_from_string(obj)
    Time.strptime(obj, '%H%M')
  end

  def slot_and_duration(times)
    from, to = split_times(times)
    duration = (time_from_string(to) - time_from_string(from)).duration

    "#{format_time_12hr(from)} for #{duration}"
  end

  def start_and_end_time(times)
    split_times(times).map(&method(:format_time_24hr)).join(' - ')
  end

  def split_times(times)
    times.split('-')
  end
end
