require 'rails_helper'

RSpec.describe DateListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { ['2017-01-01', '2017-01-02'] }

    it { expect(subject.cast(value)).to eq(value.map { |v| Date.parse(v) }) }
  end
end
