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
    }.to raise_error(Nomis::Error::Disabled, 'Nomis API is disabled')
  end

  describe 'lookup_active_prisoner', vcr: { cassette_name: :lookup_active_prisoner } do
    let(:params) {
      {
        noms_id: 'G7244GR',
        date_of_birth: Date.parse('1966-11-22')
      }
    }

    let(:prisoner) { subject.lookup_active_prisoner(params) }

    it 'returns and prisoner if the data matches' do
      expect(prisoner).to be_kind_of(Nomis::Prisoner)
      expect(prisoner.nomis_offender_id).to eq(1_502_035)
      expect(prisoner.noms_id).to eq('G7244GR')
    end

    it 'returns NullPrisoner if the data does not match', vcr: { cassette_name: :lookup_active_prisoner_nomatch } do
      params[:noms_id] = 'Z9999ZZ'
      expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
    end

    it 'returns NullPrisoner if an ApiError is raised', :expect_exception do
      allow_any_instance_of(Nomis::Client).to receive(:get).and_raise(Nomis::APIError)
      expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
      expect(prisoner).not_to be_api_call_successful
    end

    it 'logs the lookup result, api lookup time' do
      prisoner
      expect(PVB::Instrumentation.custom_log_items[:api]).to be > 1
      expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_lookup]).to be true
    end

    describe 'with no matching prisoner', vcr: { cassette_name: :lookup_active_prisoner_nomatch } do
      before do
        params[:noms_id] = 'Z9999ZZ'
      end

      it 'returns nil if the data does not match' do
        expect(prisoner).to be_instance_of(Nomis::NullPrisoner)
      end

      it 'logs the prisoner was unsucessful' do
        prisoner
        expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_lookup]).to be false
      end
    end
  end

  describe '#lookup_prisoner_details' do
    let(:prisoner_details) { described_class.instance.lookup_prisoner_details(noms_id: noms_id) }

    context 'when found', vcr: { cassette_name: :lookup_prisoner_details } do
      let(:noms_id) { 'G7244GR' }

      it 'serialises the response into a prisonwe' do
        expect(prisoner_details).
          to have_attributes(
            given_name: "UDFSANAYE",
            surname: "KURTEEN",
            date_of_birth: Date.parse('1966-11-22'),
            aliases: [],
            gender: { 'code' => 'M', 'desc' => 'Male' },
            convicted: true,
            imprisonment_status: { "code" => "SENT03", "desc" => "Adult Imprisonment Without Option CJA03" },
            iep_level: { "code" => "ENH", "desc" => "Enhanced" }
             )
      end

      it 'instruments the request' do
        prisoner_details
        expect(PVB::Instrumentation.custom_log_items[:valid_prisoner_details_lookup]).to be true
      end
    end

    context 'when an unknown prisoner', :expect_exception, vcr: { cassette_name: :lookup_prisoner_details_unknown_prisoner } do
      let(:noms_id) { 'A1459BE' }

      it { expect { prisoner_details }.to raise_error(Nomis::APIError) }
    end

    context 'when given an invalid nomis id', :expect_exception, vcr: { cassette_name: :lookup_offender_details_invalid_noms_id } do
      let(:noms_id) { 'RUBBISH' }

      it { expect { prisoner_details }.to raise_error(Nomis::APIError) }
    end
  end

  describe '#lookup_prisoner_location' do
    let(:establishment) { subject.lookup_prisoner_location(noms_id: noms_id) }

    context 'when found', vcr: { cassette_name: :lookup_prisoner_location } do
      let(:noms_id) { 'G7244GR' }

      it 'returns a Location' do
        expect(establishment).to be_valid
        expect(establishment.code).to eq 'LEI'
      end

      it 'has the internal location' do
        expect(establishment).to have_attributes(housing_location: instance_of(Nomis::HousingLocation))
        expect(establishment.housing_location.description).to eq 'LEI-F-3-005'
      end
    end

    context 'with an unknown offender', :expect_exception, vcr: { cassette_name: :lookup_prisoner_location_for_unknown_prisoner } do
      let(:noms_id) { 'A1459BE' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end

    context 'with an invalid nomis_id', :expect_exception, vcr: { cassette_name: :lookup_prisoner_location_for_bogus_prisoner } do
      let(:noms_id) { 'BOGUS' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end
  end

  describe 'prisoner_visiting_availability', vcr: { cassette_name: :prisoner_visiting_availability } do
    let(:params) {
      {
        offender_id: 1_502_035,
        start_date: '2019-11-14',
        end_date: '2019-11-24'
      }
    }

    context 'when the prisoner has availability' do
      subject { super().prisoner_visiting_availability(params) }

      it 'returns availability info containing a list of available dates' do
        expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
        expect(subject.dates.first).to eq(Date.parse('2019-11-14'))
      end

      it 'logs the number of available dates' do
        expect(subject.dates.count).to eq(PVB::Instrumentation.custom_log_items[:prisoner_visiting_availability])
      end
    end

    context 'when the prisoner has no availability' do
      # This spec has to have a hard coded date as an offender MUST be unavailable on a specific date in order for this to
      # pass.  Unfortunately we are unable to use 'travel_to' and go to the past as the JWT token skew is too large.  If this
      # test needs updating a new date will need to be added and updated as part of the VCR being recorded
      let(:params) {
        {
          offender_id: 1_502_035,
          start_date: Date.parse('2019-11-18'),
          end_date: Date.parse('2019-11-18')
        }
      }

      subject { super().prisoner_visiting_availability(params) }

      it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: :prisoner_visiting_availability_noavailability } do
        expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
        expect(subject.dates).to be_empty
      end
    end
  end

  describe 'prisoner_visiting_detailed_availability', vcr: { cassette_name: :prisoner_visiting_detailed_availability } do
    let(:slot1) { ConcreteSlot.new(2019, 11, 14, 10, 0, 11, 0) }
    let(:slot2) { ConcreteSlot.new(2019, 11, 15, 10, 0, 11, 0) }
    let(:slot3) { ConcreteSlot.new(2019, 11, 16, 10, 0, 11, 0) }
    let(:params) do
      {
        offender_id: 1_502_035,
        slots: [slot1, slot2, slot3]
      }
    end

    subject { super().prisoner_visiting_detailed_availability(params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerDetailedAvailability)
      expect(subject.dates.map(&:date)).
        to contain_exactly(slot1.to_date, slot2.to_date, slot3.to_date)
    end

    it 'logs the number of available slots' do
      subject
      expect(PVB::Instrumentation.custom_log_items[:prisoner_visiting_availability]).to eq(3)
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: :fetch_bookable_slots } do
    # There have been issues with the visit slots for Leeds in T3 and therefore we have switched to use The Verne
    # for this spec
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'VEI'),
        start_date: '2019-11-14',
        end_date: '2019-11-24'
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.time.iso8601).to eq("2019-11-14T14:00/16:00")
    end

    it 'logs the number of available slots' do
      expect(subject.count).to eq(PVB::Instrumentation.custom_log_items[:slot_visiting_availability])
    end
  end

  describe 'fetch_contact_list', vcr: { cassette_name: :fetch_contact_list } do
    let(:params) do
      {
        offender_id: 1_502_035
      }
    end

    let(:first_contact) do
      Nomis::Contact.new(
        id: 2_996_406,
        given_name: 'AELAREET',
        surname: 'ANTOINETTE',
        date_of_birth: '1990-09-22',
        gender: { code: "M", desc: "Male" },
        active: true,
        approved_visitor: true,
        relationship_type: { code: "SON", desc: "Son" },
        contact_type: {
          code: "S",
          desc: "Social/ Family"
        },
        restrictions: []
      )
    end

    subject { super().fetch_contact_list(params) }

    it 'returns an array of contacts' do
      expect(subject).to have_exactly(27).items
    end

    it 'parses the contacts' do
      expect(subject.map(&:id)).to include(first_contact.id)
    end
  end
end
