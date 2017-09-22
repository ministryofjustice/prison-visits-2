require "rails_helper"

RSpec.describe Rejection::ReasonDecorator do
  let(:reasons) { %w[reason_one reason_two] }

  describe "#checkbox_for" do
    let(:html_options) { {} }
    let(:reason) { reasons.sample }
    let(:checkbox) do
      Capybara.string(
        described_class.decorate(reasons).checkbox_for(reason, html_options)
      )
    end

    it "has a base JS class to manage rejections" do
      expect(checkbox).to have_css('.js-Rejection')
    end

    context 'when a reason is included' do
      it "add the class and data attribute to instruct the JS to show rejection messages upon selection" do
        expect(checkbox).to have_css(".js-restrictionOverride[data-override='#{reason.dasherize}']")
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
        expect(checkbox).not_to have_css('.js-restrictionOverride')
      end
    end
  end
end
