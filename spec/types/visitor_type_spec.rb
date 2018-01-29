require 'rails_helper'

RSpec.describe(VisitorType) do
  subject { described_class.new }

  describe '#cast' do
    context 'when is a visitor' do
      let(:value) { Visitor.new }

      it { expect(subject.cast(value)).to eq(value) }
    end

    context 'when is hash' do
      let(:value) { { 'date_of_birth' => '2017-01-01' } }

      it 'casts to a visitor' do
        casted = subject.cast(value)
        expect(casted).to be_a(Visitor)
        expect(casted.date_of_birth).to eq(Date.parse('2017-01-01'))
      end
    end
  end
end
