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
      months: I18n.t('date.month_names').drop(1)
    }
  end
end
