require "rails_helper"

RSpec.describe Rejection::ReasonDecorator do
  let(:reasons) { ['reason one', 'reason two'] }

  describe "#checkbox_for" do
    let(:html_options) { {} }
    let(:checkbox) do
      Capybara.string(
        described_class.decorate(reasons).checkbox_for(reason, html_options)
      )
    end

    context 'when a reason is included' do
      let(:reason) { reasons.sample }

      it "add classes to instruct the JS to show rejection messages upon selection" do
        expect(checkbox).to have_css('.js-Rejection.js-restrictionOverride')
      end

      context 'html_options' do
        let(:html_options) { { class: 'extra_class' } }

        it 'preserves previously provided classes' do
          expect(checkbox).to have_css('.js-Rejection.js-restrictionOverride.extra_class')
        end
      end
    end

    context 'when a reason is not included' do
      let(:reason) { 'reason_not_included' }

      it "does not have instruct the JS to show any rejection messages upon selection" do
        expect(checkbox).not_to have_css('.js-Rejection.js-restrictionOverride')
      end
    end
  end
end
