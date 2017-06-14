require "rails_helper"

RSpec.describe LeadVisitorDecorator, type: :decorator do
  let(:lead_visitor)          { create :lead_visitor }
  let(:contact_email_address) { lead_visitor.visit.contact_email_address }
  let(:contact_phone_no)      { lead_visitor.visit.contact_phone_no }

  subject { lead_visitor.decorate }

  describe '#contact_details' do
    let(:html) { Capybara.string(subject.contact_details) }

    it 'renders the contact details' do
      expect(html).to have_link(contact_email_address, href: "mailto:#{contact_email_address}")
      expect(html).to have_css('p', text: /#{contact_phone_no}/)
    end
  end
end
