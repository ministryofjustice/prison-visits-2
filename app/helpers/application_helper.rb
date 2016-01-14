module ApplicationHelper
  def page_title(header, glue = ' - ')
    [header, I18n.t(:app_title)].compact.join(glue)
  end

  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  def javascript_i18n
    {
      days: I18n.t('date.day_names'),
      months: I18n.t('date.month_names').drop(1),
      abbrMonths: I18n.t('date.abbr_month_names').drop(1),
      am: I18n.t('time.am'),
      pm: I18n.t('time.pm'),
      hour: I18n.t('time.hour'),
      minute: I18n.t('time.minute')
    }
  end

  def alternative_locales
    I18n.available_locales - [I18n.locale]
  end

  def add_line_breaks(str)
    safe_join(str.split(/\n/), '<br />'.html_safe)
  end
end
