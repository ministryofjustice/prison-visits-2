class VisitorDecorator < Draper::Decorator
  delegate_all

  def li(visitor_form_builder)
    h.content_tag :li, { id: h.dom_id(object), data: { banned: false, processed: false, visitor: visitor_as_json } } do
      h.render partial: 'prison/visits/visitor_contact', locals: { vf: visitor_form_builder, v: self }
    end
  end

  def date_of_birth
    object.date_of_birth.to_s(:short_nomis)
  end

  def contact_details; end

  private

  def visitor_as_json
    {
      first_name: first_name,
      last_name:  last_name,
      dob:        date_of_birth
    }
  end
end
