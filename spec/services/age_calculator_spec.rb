require 'rails_helper'

RSpec.describe AgeCalculator do
  describe 'age' do
    context 'when birthday is a normal day' do
      let(:dob) { Date.new(1980, 6, 7) }

      it 'is correct on birthday' do
        expect(subject.age(dob, Date.new(2000, 6, 7))).to eq(20)
      end

      it 'is correct on birthday eve' do
        expect(subject.age(dob, Date.new(2000, 6, 6))).to eq(19)
      end

      it 'is correct after birthday' do
        expect(subject.age(dob, Date.new(2000, 6, 8))).to eq(20)
      end

      it 'is correct on last day of year' do
        expect(subject.age(dob, Date.new(2000, 12, 25))).to eq(20)
      end

      it 'is correct on first day of year' do
        expect(subject.age(dob, Date.new(2000, 1, 1))).to eq(19)
      end
    end

    context 'when birthday is a leap year' do
      let(:dob) { Date.new(1980, 2, 29) }

      context 'in a non-leap year' do
        it 'is correct on birthday eve' do
          expect(subject.age(dob, Date.new(1999, 2, 28))).to eq(18)
        end

        it 'is correct on day after birthday' do
          expect(subject.age(dob, Date.new(1999, 3, 1))).to eq(19)
        end
      end

      context 'in a leap year' do
        it 'is correct on birthday' do
          expect(subject.age(dob, Date.new(2000, 2, 29))).to eq(20)
        end

        it 'is correct on birthday eve' do
          expect(subject.age(dob, Date.new(2000, 2, 28))).to eq(19)
        end

        it 'is correct on day after birthday' do
          expect(subject.age(dob, Date.new(2000, 3, 1))).to eq(20)
        end
      end
    end

    context 'when today is a leap day' do
      let(:today) { Date.new(2000, 2, 29) }

      it 'is correct when birthday is 28 February' do
        expect(subject.age(Date.new(1980, 2, 28), today)).to eq(20)
      end
    end
  end
end
