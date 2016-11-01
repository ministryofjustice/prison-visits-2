module DashboardHelper
  def timeline_event_html_class(event)
    classes = ['timeline__entry', "timeline__entry--#{event.state}"]
    classes << 'timeline__entry-last' if event.last
    classes * ' '
  end
end
