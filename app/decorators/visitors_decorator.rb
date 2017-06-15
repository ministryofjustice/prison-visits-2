class VisitorsDecorator < Draper::CollectionDecorator

  def render_visitors_details(visit_form_builder)
    h.render object.map(&:decorate), f: visit_form_builder
  end

end
