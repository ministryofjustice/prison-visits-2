require "rails_helper"

RSpec.describe PrisonerDetailsPresenter do
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:pvb_prisoner) { build_stubbed(:prisoner) }
  let(:nomis_prisoner) { Nomis::Prisoner.new(id: 'some offender id', noms_id: pvb_prisoner.number) }

  let(:prisoner_validation) { PrisonerValidation.new(nomis_prisoner) }

  subject { described_class.new(prisoner_validation) }

  describe '#prisoner_existance_status' do
    describe 'when the nomis api is live' do
      describe 'when this API is available' do
        describe 'with valid prisoner details' do
          describe '#details_incorrect?' do
            it { is_expected.not_to be_details_incorrect }
          end

          describe '#prisoner_existance_status' do
            it { expect(subject.prisoner_existance_status).to eq('valid') }
          end
        end

        describe 'with invalid prisoner details' do
          let(:nomis_prisoner) { Nomis::NullPrisoner.new(api_call_successful: true) }

          it { expect(subject.prisoner_existance_status).to eq('invalid') }

          describe '#details_incorrect?' do
            it { is_expected.to be_details_incorrect }
          end
        end
      end

      describe "and the API is unavailable" do
        let(:nomis_prisoner) { Nomis::NullPrisoner.new(api_call_successful: false) }

        it { expect(subject.prisoner_existance_status).to eq('unknown') }
      end
    end

    describe 'when NOMIS APIerror is disasbled' do
      before do
        switch_off_api
      end

      it { expect(subject.prisoner_existance_status).to eq('not_live') }
    end
  end
end
