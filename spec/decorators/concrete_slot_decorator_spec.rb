require "rails_helper"

RSpec.describe ConcreteSlotDecorator do
  let(:visit) { create(:visit) }
  let(:slot_errors)   { [] }
  let(:nomis_checker) { double(StaffNomisChecker, errors_for: slot_errors) }

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

    context 'when a prisoner is available' do
      let(:html_fragment) do
        Capybara.string(
          subject.label_for(form_builder)
        )
        it 'renders the chexbox' do
          expect(html_fragment).to have_css('label.block-label.date-box')
          expect(html_fragment).to have_css('span.date-box__number', text: '1')
          expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
          expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
        end
      end
    end

    context 'when a prisoner is not available' do
      let(:html_fragment) do
        Capybara.string(subject.label_for(form_builder))
      end
      let(:slot_errors)   { ['some slot errors'] }

      it 'renders the chexbox' do
        expect(html_fragment).to have_css('label.block-label.date-box.date-box--error')
        expect(html_fragment).to have_css('span.date-box__number', text: '1')
        expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
        expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
        expect(html_fragment).to have_css('span.colour--error', text: 'Prisoner unavailable')
      end
    end
  end
end
