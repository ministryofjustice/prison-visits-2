require 'rails_helper'

RSpec.describe NomisOffenderType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { Nomis::Prisoner.new }

    it { expect(subject.cast(value)).to eq(value) }
  end
end
