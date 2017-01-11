# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Nomis::Api do
  subject { described_class.instance }

  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end
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

    let(:offender) { subject.lookup_active_offender(params) }

    it 'returns and offender if the data matches' do
      expect(offender).to be_kind_of(Nomis::Offender)
      expect(offender.id).to eq(1_055_827)
    end

    it 'returns NullOffender if the data does not match', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      params[:noms_id] = 'Z9999ZZ'
      expect(offender).to be_instance_of(Nomis::NullOffender)
    end

    it 'returns NullOffender if an ApiError is raised' do
      allow_any_instance_of(Nomis::Client).to receive(:get).and_raise(Nomis::APIError)
      expect(offender).to be_instance_of(Nomis::NullOffender)
      expect(offender).not_to be_api_call_successful
    end

    it 'logs the lookup result, api lookup time' do
      offender
      expect(Instrumentation.custom_log_items[:api]).to be > 1
      expect(Instrumentation.custom_log_items[:valid_offender_lookup]).to be true
    end

    describe 'with no matching offender', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      before do
        params[:noms_id] = 'Z9999ZZ'
      end

      it 'returns nil if the data does not match' do
        expect(offender).to be_instance_of(Nomis::NullOffender)
      end

      it 'logs the offender was unsucessful' do
        offender
        expect(Instrumentation.custom_log_items[:valid_offender_lookup]).to be false
      end
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

    it 'logs the number of available dates' do
      expect(subject.dates.count).to eq(Instrumentation.custom_log_items[:visit_available_count])
    end

    it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: 'offender_visiting_availability-noavailability' } do
      params[:offender_id] = 1_055_847
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates).to be_empty
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: 'fetch_bookable_slots' } do
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'LEI'),
        start_date: Date.parse('2016-05-08'),
        end_date: Date.parse('2016-06-01')
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.iso8601).to eq('2016-05-09T10:30/11:30')
    end

    it 'logs the number of available slots' do
      expect(subject.count).to eq(Instrumentation.custom_log_items[:available_slots_count])
    end
  end
end
