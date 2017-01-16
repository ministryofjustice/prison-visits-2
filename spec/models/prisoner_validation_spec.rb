# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PrisonerValidation, type: :model do
  let(:offender) { Nomis::Offender.new(id: 'someid') }
  subject do
    described_class.new(offender)
  end

  describe 'when the NOMIS API is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    it 'the result is unknown' do
      is_expected.not_to be_valid
      expect(subject.errors[:base]).to eq(['unknown'])
    end
  end

  describe 'when the NOMIS API is enabled' do
    context 'and the API finds a match' do
      it { is_expected.to be_valid }
    end

    context 'and the API does not find a match' do
      let(:offender) { Nomis::NullOffender.new }
      it { is_expected.not_to be_valid }
    end
  end
end
