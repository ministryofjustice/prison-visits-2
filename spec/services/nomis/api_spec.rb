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

  describe 'lookup_active_offender', vcr: { cassette_name: 'lookup_active_offender' } do
    let(:params) {
      {
        noms_id: 'A1484AE',
        date_of_birth: Date.parse('1971-11-11')
      }
    }

    let(:offender) { subject.lookup_active_offender(params) }

    it 'returns and offender if the data matches' do
      expect(offender).to be_kind_of(Nomis::Offender)
      expect(offender.id).to eq(1_057_307)
      expect(offender.noms_id).to eq('A1484AE')
    end

    it 'returns NullOffender if the data does not match', vcr: { cassette_name: 'lookup_active_offender-nomatch' } do
      params[:noms_id] = 'Z9999ZZ'
      expect(offender).to be_instance_of(Nomis::NullOffender)
    end

    it 'returns NullOffender if an ApiError is raised', :expect_exception do
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

  describe '#lookup_offender_details' do
    let(:offender_details) { described_class.instance.lookup_offender_details(noms_id: noms_id) }

    context 'when found', vcr: { cassette_name: :lookup_offender_details } do
      let(:noms_id) { 'A1484AE' }

      it 'serialises the response into an Offender' do
        expect(offender_details).
          to have_attributes(
            given_name: "IZZY",
            surname: "ITSU",
            date_of_birth: Date.parse('1971-11-11'),
            aliases: [],
            gender: { 'code' => 'M', 'desc' => 'Male' },
            convicted: true,
            imprisonment_status: { 'code' => 'UNK_SENT', 'desc' => 'Unknown Sentenced' },
            iep_level: { 'code' => 'STD', 'desc' => 'Standard' }
             )
      end

      it 'instruments the request' do
        offender_details
        expect(PVB::Instrumentation.custom_log_items[:valid_offender_details_lookup]).to be true
      end
    end

    context 'when an unknown offender', :expect_exception, vcr: { cassette_name: :lookup_offender_details_unknown_offender } do
      let(:noms_id) { 'A1459BE' }

      it { expect { offender_details }.to raise_error(Nomis::APIError) }
    end

    context 'when given an invalid nomis id', :expect_exception, vcr: { cassette_name: :lookup_offender_details_invalid_noms_id } do
      let(:noms_id) { 'RUBBISH' }

      it { expect { offender_details }.to raise_error(Nomis::APIError) }
    end
  end

  describe '#lookup_offender_location' do
    let(:establishment) { subject.lookup_offender_location(noms_id: noms_id) }

    context 'when found', vcr: { cassette_name: :lookup_offender_location } do
      let(:noms_id) { 'A1484AE' }

      it 'returns a Location' do
        expect(establishment).to be_valid
      end

      it 'has the internal location' do
        expect(establishment).to have_attributes(housing_location: instance_of(Nomis::HousingLocation))
      end
    end

    context 'with an unknown offender', :expect_exception, vcr: { cassette_name: :lookup_offender_location_for_unknown_offender } do
      let(:noms_id) { 'A1459BE' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end

    context 'with an invalid nomis_id', :expect_exception, vcr: { cassette_name: :lookup_offender_location_for_bogus_offender } do
      let(:noms_id) { 'BOGUS' }

      it { expect { establishment }.to raise_error(Nomis::APIError) }
    end
  end

  describe 'offender_visiting_availability', vcr: { cassette_name: 'offender_visiting_availability' } do
    let(:params) {
      {
        offender_id: 1_057_307,
        start_date: Date.parse('2018-04-05'),
        end_date: Date.parse('2018-04-29')
      }
    }

    subject { super().offender_visiting_availability(params) }

    it 'returns availability info containing a list of available dates' do
      expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
      expect(subject.dates.first).to eq(Date.parse('2018-04-05'))
    end

    it 'logs the number of available dates' do
      expect(subject.dates.count).to eq(PVB::Instrumentation.custom_log_items[:offender_visiting_availability])
    end

    context 'when the prisoner has no availability' do
      let(:params) {
        {
          offender_id: 1_057_307,
          start_date: Date.parse('2018-04-20'),
          end_date: Date.parse('2018-04-20')
        }
      }

      it 'returns empty list of available dates if there is no availability', vcr: { cassette_name: 'offender_visiting_availability-noavailability' } do
        expect(subject).to be_kind_of(Nomis::PrisonerAvailability)
        expect(subject.dates).to be_empty
      end
    end
  end

  describe 'offender_visiting_detailed_availability', vcr: { cassette_name: 'offender_visiting_detailed_availability' } do
    let(:slot1) { ConcreteSlot.new(2018, 4, 07, 10, 0, 11, 0) }
    let(:slot2) { ConcreteSlot.new(2018, 4, 14, 10, 0, 11, 0) }
    let(:slot3) { ConcreteSlot.new(2018, 4, 21, 10, 0, 11, 0) }
    let(:params) do
      {
        offender_id: 1_057_307,
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
      expect(PVB::Instrumentation.custom_log_items[:offender_visiting_availability]).to eq(3)
    end
  end

  describe 'fetch_bookable_slots', vcr: { cassette_name: 'fetch_bookable_slots' } do
    let(:params) {
      {
        prison: instance_double(Prison, nomis_id: 'LEI'),
        start_date: Date.parse('2018-04-05'),
        end_date: Date.parse('2018-04-29')
      }
    }

    subject { super().fetch_bookable_slots(params) }

    it 'returns an array of slots' do
      expect(subject.first.time.iso8601).to eq('2018-04-05T10:00/11:30')
    end

    it 'logs the number of available slots' do
      expect(subject.count).to eq(PVB::Instrumentation.custom_log_items[:slot_visiting_availability])
    end
  end

  describe 'fetch_offender_restrictions', vcr: { cassette_name: 'fetch_offender_restrictions' } do
    let(:params) do
      {
        offender_id: 1_057_307
      }
    end

    subject { super().fetch_offender_restrictions(params) }

    it 'returns an array of restrictions' do
      expect(subject).to have_exactly(10).items
    end

    context 'with restriction_parsing' do
      let(:expected_restriction) do
        Nomis::Restriction.new(
          type: { code: 'CCTV', desc: 'CCTV' },
          effective_date: Date.parse('2017-07-24'),
          expiry_date: Date.parse('2017-09-17')
        )
      end

      let(:first_restriction) { subject.first }

      it 'parses the response' do
        expect(first_restriction.type.code).to      eq(expected_restriction.type.code)
        expect(first_restriction.type.desc).to      eq(expected_restriction.type.desc)
        expect(first_restriction.effective_date).to eq(expected_restriction.effective_date)
        expect(first_restriction.expiry_date).to    eq(expected_restriction.expiry_date)
      end
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
      expect(subject).to have_exactly(4).items
    end

    it 'parses the contacts' do
      expect(subject.map(&:id)).to include(first_contact.id)
    end
  end

  describe '#book_visit' do
    let(:params) do
      {
        lead_contact: 13_429,
        other_contacts: [],
        slot: '2018-04-14T15:30/16:30',
        override_offender_restrictions: false,
        override_visitor_restrictions: false,
        override_vo_balance: false,
        override_slot_capacity: false,
        client_unique_ref: 'client_ref_11337',
        headers: { 'X-Some-Random-Header' => 'foo' }
      }
    end

    let(:offender_id) { 1_057_307 }

    subject { super().book_visit(offender_id: offender_id, params: params) }

    describe 'idempotency' do
      context 'with a client unique ref', vcr: { cassette_name: 'book_visit_happy_retry' } do
        before do
          params[:client_unique_ref] = 'visit_id_12178'
        end

        it 'retries the request on failure' do
          expect(subject.visit_id).to eq(5_905)
          expect(PVB::Instrumentation.custom_log_items[:book_to_nomis_success]).to eq(true)
        end
      end

      context 'with no unique client ref', vcr: { cassette_name: 'book_visit_error_no_retry' } do
        before do
          params.delete(:client_unique_ref)
        end

        it 'does not retry the request on failure' do
          expect_any_instance_of(Nomis::Client).
            to receive(:post).with(
              "offenders/#{offender_id}/visits/booking",
              params,
              idempotent: false,
              options: {
                connect_timeout: 3, read_timeout: 3, write_timeout: 3,
                "X-Some-Random-Header" => "foo"
              }
            ).and_return(
              "visit_id" => nil,
              "errors" => [
                { "message" => "Overlapping visit" }]
            )
          subject
        end
      end
    end

    context 'with a happy path', vcr: { cassette_name: 'book_visit_happy_path' } do
      it 'returns the visit_id' do
        expect(subject.visit_id).to eq(5_905)
      end

      it 'instruments the outcome of the call' do
        expect { subject }.
          to change { PVB::Instrumentation.custom_log_items[:book_to_nomis_success] }.
               to eq(true)
      end

      context 'when making a request' do
        let(:client) { spy(Nomis::Client, post: { 'visit_id' => '12178' }) }

        it 'adjusts the request timeout' do
          allow(Nomis::Client).to receive(:new).and_return(client)

          described_class.instance.book_visit(offender_id: offender_id, params: params)

          expect(client).to have_received('post').
                              with(
                                "offenders/#{offender_id}/visits/booking",
                                params,
                                idempotent:      true,
                                options: {
                                  connect_timeout: Nomis::Api::BOOK_VISIT_TIMEOUT,
                                  read_timeout:    Nomis::Api::BOOK_VISIT_TIMEOUT,
                                  write_timeout:   Nomis::Api::BOOK_VISIT_TIMEOUT,
                                  "X-Some-Random-Header" => "foo"
                                }
                              )
        end
      end
    end

    context 'with a validation error', vcr: { cassette_name: 'book_visit_validation_error' } do
      it 'records the error message' do
        expect(subject.error_messages).to eq(['Overlapping visit'])
      end

      it 'instruments the outcome of the call' do
        expect { subject }.
          to change { PVB::Instrumentation.custom_log_items[:book_to_nomis_success] }.
               to eq(false)
      end
    end

    context 'with a duplicate post', vcr: { cassette_name: 'book_visit_duplicate_error' } do
      it 'records the error message' do
        expect(subject.error_messages).to eq(['Overlapping visit'])
      end
    end
  end

  describe '#cancel_visit' do
    let(:offender_id) { 1_057_307 }
    let(:params) do
      { params: { cancellation_code: 'VISCANC' } }
    end

    context 'successfully cancel a visit', vcr: { cassette_name: :cancel_visit }  do
      let(:visit_id) { 5_905 }

      it 'records the message' do
        expect(subject.cancel_visit(offender_id, visit_id, params)).
          to have_attributes(message: 'Visit Cancelled')
      end

      it 'instruments the outcome of the call' do
        expect {
          subject.cancel_visit(offender_id, visit_id, params)
        }.to change {
          PVB::Instrumentation.custom_log_items[:cancel_to_nomis_success]
        }.from(nil).to(true)
      end
    end

    context 'with an already cancelled visit', vcr: { cassette_name: :already_cancel_visit }  do
      let(:visit_id) { 5_467 }

      it 'records the message' do
        expect(subject.cancel_visit(offender_id, visit_id, params)).
          to have_attributes(error_message: 'Visit already cancelled')
      end

      it 'instruments the outcome of the call' do
        expect {
          subject.cancel_visit(offender_id, visit_id, params)
        }.to change {
          PVB::Instrumentation.custom_log_items[:cancel_to_nomis_success]
        }.from(nil).to(false)
      end
    end

    context 'with an invalid cancellation code' do
      let(:visit_id) { 5_467 }

      it 'records the error message', vcr: { cassette_name: :cancel_invalid_cancellation_code } do
        expect(subject.cancel_visit(offender_id, visit_id, params: { cancellation_code: 'POOBAR' })).
          to have_attributes(error_message: 'Invalid cancellation code')
      end
    end

    context 'with an unknown visit', vcr: { cassette_name: :cancel_visit_not_found }  do
      let(:visit_id) { 999_999 }

      it 'records the error message', :expect_exception do
        expect {
          subject.cancel_visit(offender_id, visit_id, params)
        }.to raise_error(Nomis::APIError)
      end
    end
  end
end
