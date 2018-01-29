require 'rails_helper'

RSpec.describe RestrictionType do
  subject { described_class.new }

  describe '#cast' do
    let(:casted) { Nomis::Restriction.new }

    context 'when is a restriction' do
      it { expect(subject.cast(casted)).to eq(casted) }
    end

    context 'when is a Hash' do
      it { expect(subject.cast({})).to be_a(Nomis::Restriction) }
    end
  end
end
