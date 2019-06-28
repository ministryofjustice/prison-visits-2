module ApplicationHelper
  def page_title(header, glue = ' - ')
    [header, I18n.t(:app_title)].compact.join(glue)
  end

  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end

  # rubocop:disable Rails/HelperInstanceVariable
  def ga_tracking_data
    data = { ga_tracking_id: config_item(:ga_id) }
    data[:hit_type_page] = @step_name if @step_name
    data
  end
  # rubocop:enable Rails/HelperInstanceVariable

  def alternative_locales
    I18n.available_locales - [I18n.locale]
  end

  def nav_link(link_text, link_path)
    link_options = Rails.application.routes.recognize_path(link_path)

    active_link = params[:controller] == link_options[:controller] &&
                  params[:action] == link_options[:action]

    class_name = active_link ? 'active' : ''

    content_tag(:li, class: class_name) do
      link_to link_text, link_path
    end
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
end
