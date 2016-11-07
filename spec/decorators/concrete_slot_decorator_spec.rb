require "rails_helper"

RSpec.describe ConcreteSlotDecorator do
  let(:visit) { create(:visit) }
  subject do
    described_class.decorate(
      ConcreteSlot.new(2015, 10, 23, 14, 0, 15, 30)
    )
  end

  describe '#label' do
    let(:html_fragment) { Capybara.string(subject.label(1)) }
    it 'returns the translated label for the slot' do
    end
  end

  describe '#label_for' do
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visit, subject.h, {})
    end
    let(:slot) do
      ConcreteSlot.new(2015, 11, 5, 13, 30, 14, 45)
    end
    let(:html_fragment) do
      Capybara.string(
        subject.label_for(form_builder, 0)
      )
    end
    context 'when a prisoner is available' do
      it 'renders the chexbox' do
        print html_fragment.native.to_xml
        expect(html_fragment).to have_css('label.block-label.date-box')

        expect(html_fragment).to have_css('span.date-box__number', text: '1')
        expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
        expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
      end
    end

    context 'when a prisoner is not available' do

    end
  end
end
