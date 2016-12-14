require "rails_helper"

RSpec.describe ConcreteSlotDecorator do
  let(:visit) { create(:visit) }
  let(:slot_errors)   { [] }
  let(:nomis_checker) do
    double(StaffNomisChecker,
      errors_for: slot_errors,
      prisoner_availability_unknown?: false,
      prisoner_availability_enabled?: true)
  end

  subject do
    described_class.decorate(
      ConcreteSlot.new(2015, 10, 23, 14, 0, 15, 30),
      context: {
        nomis_checker: nomis_checker,
        index: 0
      }
    )
  end

  describe '#label_for' do
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visit, subject.h, {})
    end
    let(:slot) do
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    end
    let(:html_fragment) do
      Capybara.string(subject.slot_picker(form_builder))
    end

    context 'when a prisoner is available' do
      it 'renders the checkbox' do
        expect(html_fragment).to have_css('label.block-label.date-box')
        expect(html_fragment).to have_css('span.date-box__number', text: '1')
        expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
        expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
      end
    end

    context 'when a prisoner is not available' do
      let(:slot_errors) { ['prisoner_not_available'] }

      it 'renders the chexbox' do
        expect(html_fragment).to have_css('label.block-label.date-box.date-box--error')
        expect(html_fragment).to have_css('span.date-box__number', text: '1')
        expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
        expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
        expect(html_fragment).to have_css('span.colour--error', text: 'Prisoner unavailable')
      end
    end

    context 'when the api is disabled' do
      before do
        expect(nomis_checker).to receive(:prisoner_availability_enabled?).and_return(false)
      end

      it 'renders the checkbox without errors' do
        expect(html_fragment).to have_css('label.block-label.date-box')
        expect(html_fragment).to have_css('span.date-box__number', text: '1')
        expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
        expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
      end
    end
  end
end
