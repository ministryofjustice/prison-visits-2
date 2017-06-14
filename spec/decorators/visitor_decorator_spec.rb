require "rails_helper"

RSpec.describe VisitorDecorator do
  let(:visitor) { create :visitor }

  subject { visitor.decorate }

  describe '#contact_details' do
    let(:html) { subject.contact_details }

    it 'is blank' do
      expect(html).to be_blank
    end
  end

  describe '#li' do
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visitor, subject.h, {})
    end

    let(:html) { Capybara.string(subject.li(form_builder)) }
    let(:visitor_to_json) do
      {
        first_name: visitor.first_name,
        last_name:  visitor.last_name,
        dob:        visitor.date_of_birth
      }.to_json
    end

    it "renders the li with all the attributes" do
      expect(html).
        to have_css("li[data-banned='false'][data-processed='false'][data-visitor='#{visitor_to_json}']")
    end

    it 'displays name' do
      expect(html).to have_css('.bold-small', text: /#{visitor.full_name}/)
    end
  end
end
