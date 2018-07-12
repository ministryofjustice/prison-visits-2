require "rails_helper"

RSpec.describe PrisonerLocationPresenter do
  let(:establishment_code) { 'LCI' }
  let(:establishment)      do
    Nomis::Establishment.new(
      code:             'LCI',
      housing_location: { description: 'some_internal_location' }
    )
  end
  let(:prisoner)           { Nomis::Prisoner.new(id: '123', noms_id: 'AR234RG') }

  let(:prisoner_location_validation) do
    PrisonerLocationValidation.new(prisoner, establishment_code)
  end

  subject { described_class.new(prisoner_location_validation) }

  describe '#status' do
    describe 'when NOMIS API is live' do
      describe 'when the API call is successful' do
        before do
          allow(prisoner_location_validation).
            to receive(:establishment).and_return(establishment)
        end

        describe 'when the location is valid' do
          it { expect(subject.status).to be nil }
        end

        describe 'when the location is invalid' do
          let(:establishment_code) { 'LEI' }

          it { expect(subject.status).to eq('location_invalid') }
        end
      end

      describe 'when the API returns an error', :expect_exception do
        before do
          simulate_api_error_for(:lookup_prisoner_location)
        end

        it { expect(subject.status).to eq('location_unknown') }
      end
    end

    describe 'when NOMIS API is not live' do
      before do
        switch_off_api
      end

      it { expect(subject.status).to eq('not_live') }
    end
  end

  describe '#internal_location' do
    describe 'when the API call is successful' do
      before do
        allow(prisoner_location_validation).
          to receive(:establishment).and_return(establishment)
      end

      describe 'when the location is valid' do
        it { expect(subject.internal_location).to eq('some_internal_location') }
      end

      describe 'when the location is invalid' do
        let(:establishment_code) { 'LEI' }

        it { expect(subject.internal_location).to be nil }
      end
    end

    describe 'when the API returns an error', :expect_exception do
      before do
        simulate_api_error_for(:lookup_prisoner_location)
      end

      it { expect(subject.internal_location).to be nil }
    end
  end
end
