require 'rails_helper'

RSpec.describe PrisonerNumberType do
  subject { described_class.new }

  describe '#cast' do
    let(:value) { ' ab1234c ' }

    it 'strips and upcases' do
      expect(subject.cast(value)).to eq('AB1234C')
    end
  end
end
