require 'rails_helper'

RSpec.describe Nomis::Offender::Restrictions do
  subject { described_class.new(args) }

  describe '#restrictions' do
    let(:unparsed_restriction) do
      {
        'type' => { 'code' => 'BAN', 'desc' => 'Banned' },
        'effective_date' => '11-07-2017',
        'expiry_date' => '20-07-2017'
      }
    end

    let(:args) do
      { 'restrictions' => [unparsed_restriction] }
    end

    let(:expected_restriction) { Nomis::Restriction.new(unparsed_restriction) }

    context 'with no restriction' do
      let(:args) do
        {}
      end

      it 'has an empty default restriction list' do
        expect(subject.restrictions).to eq([])
      end
    end

    it 'parses the attributes to an array of restrictions' do
      expect(subject.restrictions).to have(1).item
      restriction = subject.restrictions.first

      expect(restriction.type.code).to      eq(expected_restriction.type.code)
      expect(restriction.type.desc).to      eq(expected_restriction.type.desc)
      expect(restriction.effective_date).to eq(expected_restriction.effective_date)
      expect(restriction.expiry_date).to    eq(expected_restriction.expiry_date)
    end
  end

  describe '#api_call_successful?' do
    let(:args) { {} }

    before do
      subject.api_call_successful = false
    end

    it { expect(subject).not_to be_api_call_successful }
  end
end
