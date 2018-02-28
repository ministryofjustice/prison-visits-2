require "rails_helper"

RSpec.describe PrisonerDetailsPresenter do
  let(:prison)   { build_stubbed(:prison, name: 'Pentonville') }
  let(:prisoner) { build_stubbed(:prisoner) }
  let(:offender) { Nomis::Offender.new(id: prisoner.number, noms_id: 'some_noms_id') }

  let(:prisoner_validation) { PrisonerValidation.new(offender) }
  let(:prisoner_location)   { PrisonerLocationValidation.new(offender, prison.nomis_id) }

  subject { described_class.new(prisoner_validation, prisoner_location) }

  describe '#prisoner_existance_status' do
    describe 'when the nomis api is live' do
      before do
        switch_on :nomis_staff_prisoner_check_enabled
      end

      describe 'when this API is available' do
        describe 'with valid prisoner details' do
          let(:api_call_successful) { true }
          let(:code) { prison.nomis_id }

          let(:establishment) do
            Nomis::Establishment.new(code: code, api_call_successful: api_call_successful)
          end

          before do
            mock_nomis_with(:lookup_offender_location, establishment)
          end

          describe '#details_incorrect?' do
            it { is_expected.not_to be_details_incorrect }
          end

          describe 'with valid location' do
            it do
              expect(subject.prisoner_existance_status).
                to eq('valid')
            end
          end

          describe 'with an invalid location' do
            let(:code) { 'CCC' }

            it { expect(subject.prisoner_existance_status).to eq('valid') }
            it { expect(subject.prisoner_location_error).to eq('location_invalid') }
          end

          describe 'with an unkown location' do
            let(:api_call_successful) { false }

            it { expect(subject.prisoner_existance_status).to eq('valid') }
            it { expect(subject.prisoner_location_error).to eq('location_unknown') }
          end
        end

        describe 'with invalid prisoner details' do
          let(:offender) { Nomis::NullOffender.new(api_call_successful: true) }

          describe 'and the prisoner location is valid' do
            it do
              expect(subject.prisoner_existance_status).
                to eq('invalid')
            end

            describe '#details_incorrect?' do
              it { is_expected.to be_details_incorrect }
            end
          end
        end
      end

      describe "and the API is unavailable" do
        let(:offender) { Nomis::NullOffender.new(api_call_successful: false) }

        it { expect(subject.prisoner_existance_status).to eq('unknown') }
      end
    end
  end
end
