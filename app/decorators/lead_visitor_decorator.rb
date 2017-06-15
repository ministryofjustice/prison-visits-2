class LeadVisitorDecorator < VisitorDecorator

  def contact_details
    h.render 'prison/lead_visitors/contact_details', visit: object.visit
  end

end
