require 'rails_helper'

RSpec.describe PrisonType do
  subject { described_class.new }

  describe '#cast' do
    let(:prison) { FactoryBot.build_stubbed(:prison) }

    it { expect(subject.cast(prison)).to eq(prison) }
  end
end
