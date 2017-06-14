class LeadVisitorDecorator < VisitorDecorator

  def contact_details
    h.render 'lead_visitors/contact_details', visit: object.visit
  end

end
