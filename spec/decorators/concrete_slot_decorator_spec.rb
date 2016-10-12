require "rails_helper"

RSpec.describe ConcreteSlotDecorator do
  subject do
    described_class.decorate(
      ConcreteSlot.new(2015, 10, 23, 14, 0, 15, 30)
    )
  end

  describe '#label' do
    let(:html_fragment) { Capybara.string(subject.label(1)) }
    it 'returns the translated label for the slot' do
      expect(html_fragment).to have_css('span.date-box__number', text: '1')
      expect(html_fragment).to have_css('span.date-box__day',    text: 'Friday')
      expect(html_fragment).to have_text('23 October 2015 14:00–15:30')
    end
  end
end
