ActionView::Base.field_error_proc = proc do |html_tag, _instance_tag|
  html_tag
end
