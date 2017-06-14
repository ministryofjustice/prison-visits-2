class VisitorsDecorator < Draper::CollectionDecorator

  def render_visitors_details(visitor_form_builder)
    h.render object.map(&:decorate), vf: visitor_form_builder
  end

end
