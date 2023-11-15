module DateHelper
  def format_date(datetime)
    datetime.to_date.to_fs(:short_abbrev)
  end

  def format_date_of_birth(datetime)
    I18n.l(datetime.to_date, format: :date_of_birth)
  end

  def format_date_without_year(datetime)
    return unless datetime

    I18n.l(datetime.to_date, format: :date_without_year)
  end

  def format_date_day(datetime)
    I18n.l(datetime.to_date, format: '%A')
  end

  def format_time_12hr(time)
    I18n.l(time, format: :twelve_hour)
  end

  def format_time_24hr(time)
    I18n.l(time, format: :twenty_four_hour)
  end

  def format_slot_begin_time_for_public(slot)
    I18n.t(
      'formats.slot.public.begin_only',
      date: format_date_without_year(slot.begin_at.to_date),
      time: format_time_12hr(slot.begin_at)
    )
  end

  def format_slot_for_public(slot)
    I18n.t(
      'formats.slot.public.full',
      date: format_date_without_year(slot.begin_at.to_date),
      time: format_time_12hr(slot.begin_at),
      duration: format_duration(slot.duration)
    )
  end

  def format_slot_for_staff(slot)
    I18n.t(
      'formats.slot.staff',
      date: slot.begin_at.to_date.to_fs(:full_nomis),
      begin: format_time_24hr(slot.begin_at),
      end: format_time_24hr(slot.end_at)
    )
  end

  def format_visit_slot_date_for_staff(visit)
    slot = visit.slot_granted || visit.slots.first
    slot.to_date.to_fs(:short_nomis)
  end

  def format_visit_slot_times_for_staff(visit)
    slot = visit.slot_granted || visit.slots.first
    format_slot_times(slot)
  end

  def format_slot_times(slot)
    begin_at = slot.begin_at.strftime('%H:%M')
    end_at = slot.end_at.strftime('%H:%M')

    "#{begin_at}–#{end_at}"
  end

private

  def format_duration(secs)
    hours = secs.to_i / 3600
    minutes = (secs.to_i / 60) % 60

    parts = []
    parts << I18n.t('formats.duration.hours', count: hours) if hours > 0
    parts << I18n.t('formats.duration.minutes', count: minutes) if minutes > 0

    parts.join(I18n.t('formats.duration.glue'))
  end
end
