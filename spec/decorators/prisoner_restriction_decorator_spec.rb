require 'rails_helper'

RSpec.describe PrisonerRestrictionDecorator do
  let(:prisoner_restriction) do
    Nomis::Restriction.new(
      effective_date: effective_date,
      expiry_date: expiry_date
    )
  end

  let(:effective_date) { Date.parse('2017-11-15') }

  subject { described_class.decorate(prisoner_restriction) }

  describe '#formatted_date' do
    context 'with no expiry date' do
      let(:expiry_date) { nil }

      it { expect(subject.formatted_date).to eq('15/11/2017') }
    end

    context 'with expiry date' do
      let(:expiry_date) { Date.parse('2017-11-17') }

      it { expect(subject.formatted_date).to eq('15/11/2017 to 17/11/2017') }
    end
  end
end
