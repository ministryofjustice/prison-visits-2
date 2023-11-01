require 'rails_helper'

RSpec.describe DateListType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { %w[2017-01-01 2017-01-02] }

    it do
      expect(subject.cast(value))
        .to all(be_instance_of(Date))
    end
  end
end
