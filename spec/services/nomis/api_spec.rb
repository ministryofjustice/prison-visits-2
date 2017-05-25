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
      expect(offender.noms_id).to eq('A1459AE')
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
      expect(PVB::Instrumentation.custom_log_items[:api]).to be > 1
      expect(PVB::Instrumentation.custom_log_items[:valid_offender_lookup]).to be true
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
        expect(PVB::Instrumentation.custom_log_items[:valid_offender_lookup]).to be false
      end
    end
  end

  describe '#lookup_offender_location' do
    let(:establishment) { subject.lookup_offender_location(noms_id: noms_id) }

    context 'when found', vcr: { cassette_name: :lookup_offender_location } do
      let(:noms_id) { 'A1459AE' }

      it 'returns a Location' do
        expect(establishment).to be_valid
      end
    end

    context 'with an unknown offender', vcr: { cassette_name: :lookup_offender_location_for_unknown_offender } do
      let(:noms_id) { 'A1459BE' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end

    context 'with an invalid nomis_id', vcr: { cassette_name: :lookup_offender_location_for_bogus_offender } do
      let(:noms_id) { 'BOGUS' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
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
      expect(subject.dates.count).to eq(PVB::Instrumentation.custom_log_items[:offender_visiting_availability])
    end

    it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: 'offender_visiting_availability-noavailability' } do
      params[:offender_id] = 1_055_847
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates).to be_empty
    end
  end

  describe 'offender_visiting_detailed_availability', vcr: { cassette_name: 'offender_visiting_detailed_availability' } do
    let(:slot1) { ConcreteSlot.new(2017, 3, 14, 10, 0, 11, 0) }
    let(:slot2) { ConcreteSlot.new(2017, 3, 21, 10, 0, 11, 0) }
    let(:slot3) { ConcreteSlot.new(2017, 3, 22, 10, 0, 11, 0) }
    let(:params) do
      {
        offender_id: 1_055_827,
        slots: [slot1, slot2, slot3]
      }
    end

    subject { super().offender_visiting_detailed_availability(params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerDetailedAvailability)
      expect(subject.dates.map(&:date)).
        to contain_exactly(slot1.to_date, slot2.to_date, slot3.to_date)
    end

    it 'logs the number of available slots' do
      subject
      expect(PVB::Instrumentation.custom_log_items[:offender_visiting_availability]).to eq(2)
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: 'fetch_bookable_slots' } do
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'LEI'),
        start_date: Date.parse('2017-02-01'),
        end_date: Date.parse('2017-02-20')
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.time.iso8601).to eq('2017-02-02T10:30/11:30')
    end

    it 'logs the number of available slots' do
      expect(subject.count).to eq(PVB::Instrumentation.custom_log_items[:slot_visiting_availability])
    end
  end

  describe 'fetch_contact_list', vcr: { cassette_name: 'fetch_contact_list' } do
    let(:params) do
      {
        offender_id: 1_057_307
      }
    end

    let(:first_contact) do
      Nomis::Contact.new(
        id: 12_588,
        given_name: 'BILLY',
        surname: 'JONES',
        date_of_birth: '1970-01-01',
        gender: { code: "M", desc: "Male" },
        active: true,
        approved_visitor: true,
        relationship_type: { code: "FRI", desc: "Friend" },
        contact_type: {
          code: "S",
          desc: "Social/ Family"
        },
        restrictions: [
          {
            effective_date: '2017-03-02',
            expiry_date: '2017-04-02',
            type: { code: "BAN", desc: "Banned" }
          }
        ]
      )
    end

    subject { super().fetch_contact_list(params) }

    it 'returns an array of contacts' do
      expect(subject.count).to eq(4)
    end

    it 'parses the contacts' do
      expect(subject.first.id).to eq(first_contact.id)
    end
  end
end
