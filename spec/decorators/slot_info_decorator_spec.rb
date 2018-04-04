require "rails_helper"

RSpec.describe SlotInfoDecorator do
  let(:slot) { '1400-1610' }

  subject  {  described_class.decorate(slot) }

  describe '#formatted' do
    it { expect(subject.formatted).to eq('14:00 - 16:10') }
  end
end
