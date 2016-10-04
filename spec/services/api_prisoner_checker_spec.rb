require 'rails_helper'

RSpec.describe ApiPrisonerChecker do
  subject do
    described_class.new(noms_id: noms_id, date_of_birth: date_of_birth)
  end

  let(:noms_id) { 'A1234BC' }
  let(:date_of_birth) { Time.zone.today }

  before do
    allow(PrisonerValidation).
      to receive(:new).
      with(noms_id: noms_id, date_of_birth: date_of_birth).
      and_return(validator)
  end

  let(:validator) do
    double(PrisonerValidation, valid?: anything, errors: { base: errors })
  end

  describe '#valid?' do
    describe 'when there are no errors' do
      let(:errors) { [] }
      it { is_expected.to be_valid }
    end

    describe "when the error is 'unknown'" do
      let(:errors) { ['unknown'] }
      it { is_expected.to be_valid }
    end

    describe "when the error is 'prisoner_does_not_exist'" do
      let(:errors) { ['prisoner_does_not_exist'] }
      it { is_expected.to_not be_valid }
    end
  end

  describe '#errors' do
    let(:errors) { ['something'] }
    it 'returns the error from the validator' do
      expect(subject.error).to eq('something')
    end
  end
end
