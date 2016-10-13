require 'rails_helper'

RSpec.describe StaffNomisChecker do
  let(:instance) { described_class.new(visit) }
  let(:visit) { FactoryGirl.build_stubbed(:visit, prisoner: prisoner) }
  let(:prisoner) { FactoryGirl.build_stubbed(:prisoner) }

  describe '#prisoner_existance_status' do
    subject { instance.prisoner_existance_status }

    describe 'when the nomis api is not live' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(false)
      end

      it { is_expected.to eq('not_live') }
    end

    describe 'when the nomis api is live' do
      before do
        allow(Nomis::Api).to receive(:enabled?).and_return(true)

        expect(PrisonerValidation).
          to receive(:new).
          with(noms_id: prisoner.number,
               date_of_birth: prisoner.date_of_birth).
          and_return(validator)
      end

      let(:validator) do
        double(PrisonerValidation, valid?: true, errors: { base: errors })
      end

      describe 'and there are no errors' do
        let(:errors) { [] }

        it { is_expected.to eq('valid') }
      end

      describe "and the error is 'unknown'" do
        let(:errors) { ['unknown'] }

        it { is_expected.to eq('unknown') }
      end

      describe "and the error is 'prisoner_does_not_exist'" do
        let(:errors) { ['prisoner_does_not_exist'] }

        it { is_expected.to eq('invalid') }
      end
    end
  end

  describe 'prisoner_existance_error' do
    before do
      expect(PrisonerValidation).
        to receive(:new).
        with(noms_id: prisoner.number,
             date_of_birth: prisoner.date_of_birth).
        and_return(validator)
    end

    let(:validator) do
      double(PrisonerValidation, valid?: true, errors: { base: errors })
    end
    let(:errors) { ['something'] }

    it 'is the error from the prisoner validation' do
      expect(instance.prisoner_existance_error).to eq('something')
    end
  end
end
