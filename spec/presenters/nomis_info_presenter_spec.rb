require "rails_helper"

RSpec.describe NomisInfoPresenter do
  let(:id)                  { '123' }
  let(:api_call_successful) { true }
  let(:offender)            { Nomis::Offender.new(id: id, noms_id: 'AB132ER') }
  let(:location_params)     { { code: 'LCI', desc: 'Leicester' } }
  let(:establishment)       { Nomis::Establishment.new(location_params) }

  let(:prisoner_validation) { PrisonerValidation.new(offender) }
  let(:prisoner_location)   { PrisonerLocationValidation.new(offender, 'LCI')  }

  before do
    allow(prisoner_location).to receive(:establishment).and_return(establishment)
  end

  subject { described_class.new(prisoner_validation, prisoner_location) }

  describe '#prisoner_validation_status' do
    describe 'when the API is live' do
      describe 'when verifying the prisoner number and date of birth' do
        describe 'with a successful API call' do
          describe 'when given the correct prisoner details and location' do
            it { expect(subject.notice).to be nil }
          end

          describe 'when given incorrect prisoner details' do
            let(:id) { nil }

            it { expect(subject.notice).to eq('prisoner_does_not_exist') }
          end

          describe 'when given incorrect incorrect location' do
            let(:location_params) { { code: 'LEI', desc: 'Leeds' } }

            it { expect(subject.notice).to eq('location_invalid') }
          end

          describe 'when given an incorrect location' do
            let(:location_params) { { code: 'LEI', desc: 'Leeds' } }

            it { expect(subject.notice).to eq('location_invalid') }
          end

          describe 'when given location API call fails' do
            let(:location_params) { { api_call_successful: false } }

            it { expect(subject.notice).to eq('location_unknown') }
          end
        end

        describe 'when the API call fails' do
          let(:offender) { Nomis::NullPrisoner.new }

          it { expect(subject.notice).to eq('unknown') }
        end
      end
    end

    describe 'when NOMIS API is not live' do
      before do
        switch_off_api
      end

      it { expect(subject.notice).to eq('not_live') }
    end
  end
end
