require 'rails_helper'

RSpec.describe Nomis::Api do
  subject { described_class.instance }

  it 'is implicitly enabled if the api host is configured' do
    expect(Rails.configuration).to receive(:nomis_api_host).and_return(nil)
    expect(described_class.enabled?).to be false

    expect(Rails.configuration).to receive(:nomis_api_host).and_return('http://example.com/')
    expect(described_class.enabled?).to be true
  end

  it 'fails if code attempts to use the client when disabled' do
    expect(described_class).to receive(:enabled?).and_return(false)
    expect {
      described_class.instance
    }.to raise_error(Nomis::DisabledError, 'Nomis API is disabled')
  end

  describe 'lookup_active_offender', vcr: { cassette_name: 'lookup_active_offender' } do
    let(:params) {
      {
        noms_id: 'A1459AE',
        date_of_birth: Date.parse('1976-06-12')
      }
    }

    subject { super().lookup_active_offender(params) }

    it 'returns and offender if the data matches' do
      expect(subject).to be_kind_of(Nomis::Offender)
      expect(subject.id).to eq(1_055_827)
    end

    it 'returns nil if the data does not match', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      params[:noms_id] = 'Z9999ZZ'
      expect(subject).to be_nil
    end
  end

  describe 'offender_visiting_availability', vcr: { cassette_name: 'offender_visiting_availability' } do
    let(:params) {
      {
        offender_id: 1_055_827,
        start_date: Date.parse('2016-05-01'),
        end_date: Date.parse('2016-05-21')
      }
    }

    subject { super().offender_visiting_availability(params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates.first).to eq(Date.parse('2016-05-01'))
    end

    it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: 'offender_visiting_availability-noavailability' } do
      params[:offender_id] = 1_055_847
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates).to be_empty
    end

    it 'is an error if the offender does not exist', vcr: { cassette_name: 'offender_visiting_availability-invalid_offender' } do
      params[:offender_id] = 999_999
      expect { subject }.to raise_error(Nomis::NotFound, 'Unknown offender')
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: 'fetch_bookable_slots' } do
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'LEI'),
        start_date: Date.parse('2016-04-08'),
        end_date: Date.parse('2016-05-01')
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.iso8601).to eq('2016-04-09T09:00/10:00')
    end
  end
end
