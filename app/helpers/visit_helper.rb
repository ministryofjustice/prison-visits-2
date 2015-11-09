module VisitHelper
  def visiting_slots
    prison.slots.inject({}) do |hash, (day, slots)|
      hash.merge({
        day.to_sym => slots.map { |s| s.split('-') }
      })
    end
  end

  def current_slots
    visit.slots.map { |s| s.date + '-' + s.times }
  end

  def prison_names
    Prison.names
  end

  delegate :adult_age, :phone, :postcode, :email, :slot_anomalies,
    to: :prison, prefix: :prison
  delegate :prison_name, :prison, to: :visit

  def prison_email_link
    mail_to prison.email
  end

  def prison_address(glue='<br>'.html_safe)
    safe_join(prison.address, glue)
  end

  def prison_url(visit)
    [
      PRISON_FINDER_ENDPOINT,
      visit.prison_name.parameterize
    ].join('/')
  end

  def prison_link(source=visit, link_text=nil)
    unless link_text
      link_text = "#{source.prison_name.capitalize} prison"
    end
    link_to link_text, prison_url(visit), :rel => 'external'
  end

  def has_anomalies?(day)
    prison_slot_anomalies && prison_slot_anomalies.keys.include?(day)
  end

  def anomalies_for_day(day)
    return prison_slot_anomalies[day].map do |slot|
      slot.split('-')
    end
  end

  def slots_for_day(day)
    if has_anomalies? day
      return anomalies_for_day day
    else
      return visiting_slots[day.strftime('%a').downcase.to_sym]
    end
  end

  def when_to_expect_reply
    schedule = PrisonSchedule.new(prison)
    format_date_of_reply(schedule.confirmation_email_date)
  end

  def prison_specific_id_requirements(prison)
    template_path = Rails.root.join('app', 'views', 'content')
    candidates = [
      "_id_#{prison.nomis_id}.md",
      '_standard_id_requirements.md'
    ].map { |filename| template_path.join(filename) }
    File.read(candidates.find { |path| File.exist?(path) })
  end

  def weeks_start
    Time.zone.today.beginning_of_week
  end

  def weeks_end
    (Time.zone.today + Slot::BOOKABLE_DAYS.days).end_of_month.end_of_week
  end

  def weeks
    (weeks_start..weeks_end).group_by(&:beginning_of_week)
  end

  def tag_with_today?(day)
    day == Time.zone.today
  end

  def tag_with_month?(day)
    day.beginning_of_month == day
  end

  def last_initial(name, glue=';')
    last_name(name, glue).chars.first.upcase + '.'
  end

  def first_name(name, glue=';')
    name.split(glue).first
  end

  def last_name(name, glue=';')
    name.split(glue)[1]
  end

  def visitor_names(visitors)
    visitors.inject([]) do |arr, visitor|
      arr << visitor.full_name(';')
    end
  end
end
