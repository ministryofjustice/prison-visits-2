require "rails_helper"

RSpec.describe AccessibleDate do
  let(:attributes) { { year: '2017', month: '12', day: '25' } }

  subject { described_class.new(attributes) }

  it { is_expected.to be_valid }

  describe 'validations' do
    it { is_expected.to validate_presence_of :year }
    it { is_expected.to validate_presence_of :month }
    it { is_expected.to validate_presence_of :day }

    context 'with an invalid date' do
      let(:attributes) { { year: '2017', month: '13', day: '25' } }

      it { is_expected.not_to be_valid }
    end

    context 'with no date parts set' do
      let(:attributes) { { year: '', month: '', day: '' } }

      it { is_expected.to be_valid }
    end
  end

  describe 'to_date' do
    it 'is serialized correctly' do
      expect(subject.to_date).to eq(Date.new(2017, 12, 25))
    end

    context 'with no date parts set' do
      let(:attributes) { { year: '', month: '', day: '' } }

      it 'returns nil' do
        expect(subject.to_date).to be_nil
      end
    end
  end
end
