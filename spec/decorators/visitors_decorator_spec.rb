require "rails_helper"

RSpec.describe VisitorsDecorator, type: :decorator do
  let(:visit) { create :visit_with_two_visitors }
  subject { described_class.decorate(visit.visitors) }

  it { is_expected.to be_decorated }

  describe 'rendering the visitors collection' do

    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visit.visitors, subject.h, {})
    end

    let(:html) { Capybara.string(subject.render_visitors_details(form_builder)) }

    it 'renders all the visitors contact details panels' do
      expect(html).to have_css("#lead_visitor_#{visit.lead_visitor.id}")
      visit.additional_visitors.each do |visitor|
        expect(html).to have_css("#visitor_#{visitor.id}")
      end
    end
  end
end
