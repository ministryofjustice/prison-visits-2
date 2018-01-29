require 'rails_helper'

RSpec.describe NormalisedConcreteSlotType do
  subject { described_class.new }

  describe '#cast' do
    let(:casted) { ConcreteSlot.parse('2016-01-01T10:00/11:00') }
    let(:value) { '2016-01-01T10:01/11:00' }

    it { expect(subject.cast(value)).to eq(casted) }
  end
end
