require 'rails_helper'

RSpec.describe ConcreteSlotType do
  subject { described_class.new }

  describe '#cast' do
    let(:casted) { ConcreteSlot.parse('2016-02-15T04:00/04:30') }

    context 'with a String' do
      let(:value) { '2016-02-15T04:00/04:30' }

      it { expect(subject.cast(value)).to eq(casted) }
    end

    context 'with a ConcreteSlot' do
      it { expect(subject.cast(casted)).to eq(casted) }
    end
  end
end
