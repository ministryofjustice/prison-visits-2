module ApplicationHelper
  def page_title(header, glue = ' - ')
    [header, I18n.t(:app_title)].compact.join(glue)
  end

  def markdown(source)
    Kramdown::Document.new(source).to_html.html_safe
  end
end
