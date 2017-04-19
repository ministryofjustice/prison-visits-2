require 'rails_helper'

RSpec.describe VisitorDecorator do
  let(:visitor) { Visitor.new }
  subject(:instance) { described_class.new(visitor) }

  describe '#banned_until' do
    subject { instance.banned_until }

    context 'when is not set on the object' do
      before do
        visitor.banned_until = nil
      end

      it 'returns an accessible date' do
        is_expected.to be_a(AccessibleDate)
      end
    end

    context 'when is set on the object' do
      context 'as a hash' do
        before do
          visitor.banned_until = { year: 2099, month: 30, day: 32 }
        end

        it 'returns an accessible date' do
          is_expected.to be_a(AccessibleDate)
        end
      end

      context 'as a date' do
        let(:date) { Date.parse('2017-01-01') }

        before do
          visitor.banned_until = date
        end

        it 'returns an accessible date' do
          is_expected.to be_a(AccessibleDate)
        end
      end
    end
  end
end
