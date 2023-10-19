require 'rails_helper'

RSpec.describe ApiSlotAvailability, type: :model do
  let(:start_date) { Date.new(2016, 4, 2) }
  let!(:prison) { create(:prison) }
  let(:prisoner_params) {
    {
      prisoner_number: 'a1234bc',
      prisoner_dob: Date.parse('1970-01-01'),
      start_date: start_date
    }
  }
  let(:default_prison_slots) {
    [
      "2016-04-11T14:00/16:10",
      "2016-04-12T09:00/10:00",
      "2016-04-12T14:00/16:10",
      "2016-04-18T14:00/16:10",
      "2016-04-19T09:00/10:00",
      "2016-04-19T14:00/16:10",
      "2016-04-25T14:00/16:10",
      "2016-04-26T09:00/10:00",
      "2016-04-26T14:00/16:10"
    ]
  }
  let(:end_date) { Date.new(2016, 4, 28) }

  subject { described_class.new(prison: prison, use_nomis_slots: false, start_date: start_date, end_date: end_date) }

  before do
    allow(Nomis::Api)
      .to receive(:instance).and_return(instance_double(Nomis::Api))
  end

  around do |example|
    travel_to Time.zone.local(2016, 3, 31) do
      example.run
    end
  end

  context 'when the api is disabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    it 'fetches slot availability from the prison' do
      expect(subject.slots.map(&:iso8601)).to eq(default_prison_slots)
    end
  end

  context 'when the api is enabled' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(true)
    end

    it 'fetches slot availability from the prison by default' do
      expect(subject.slots.map(&:iso8601)).to eq(default_prison_slots)
    end

    describe 'fetching available slots from NOMIS' do
      subject { described_class.new(prison: prison, use_nomis_slots: true, start_date: start_date, end_date: end_date) }

      context 'when the prison slots feature is enabled' do
        let(:prison) {
          create(:prison,
                 nomis_concrete_slots: default_prison_slots.map { |s| ConcreteSlot.parse(s) }.map { |cs|
                   build(:nomis_concrete_slot,
                         date: Date.new(cs.year, cs.month, cs.day),
                         start_hour: cs.begin_hour,
                         start_minute: cs.begin_minute,
                         end_hour: cs.end_hour,
                         end_minute: cs.end_minute)
                 }).tap do |prison|
            switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
          end
        }

        it 'requests slots from NOMIS' do
          expect(Nomis::Api.instance).to receive(:fetch_bookable_slots)
            .with(
              prison: prison,
              start_date: Date.parse('2016-04-07'),
              end_date: Date.parse('2016-04-28')
            )
            .and_return(Struct.new(:slots).new([Struct.new(:time).new(ConcreteSlot.parse('2016-04-12T09:00/10:00'))]))

          expect(subject.slots.map(&:iso8601)).to eq(['2016-04-12T09:00/10:00'])
        end

        it 'falls back to hard-coded slots if NOMIS call fails' do
          allow(Nomis::Api.instance).to receive(:fetch_bookable_slots)
                                          .and_raise(Excon::Error, 'Fail')
          expect(Rails.logger).to receive(:warn).with(
            'Error calling the NOMIS API: #<Excon::Error: Fail>'
                                  )

          expect(subject.slots.map(&:iso8601)).to eq(default_prison_slots)
        end
      end
    end

    describe 'restricting by prisoner availability' do
      it 'can intersect available slots with prisoner availability' do
        offender = Nomis::Prisoner.new(id: 123)
        prisoner_availability = Nomis::PrisonerAvailability.new(
          dates: %w[2016-04-12 2016-04-25]
        )

        expect(Nomis::Api.instance).to receive(:lookup_active_prisoner)
          .with(noms_id: 'a1234bc', date_of_birth: Date.parse('1970-01-01'))
          .and_return(offender)
        expect(Nomis::Api.instance).to receive(:prisoner_visiting_availability)
          .and_return(prisoner_availability)

        expect(subject.prisoner_available_dates(**prisoner_params)).to eq([Date.new(2016, 4, 12), Date.new(2016, 4, 25)])
      end

      it 'returns only prison slots if the NOMIS API is disabled' do
        expect(Nomis::Api).to receive(:enabled?).and_return(false)
        expect(Nomis::Api.instance).not_to receive(:lookup_active_prisoner)
        expect(Nomis::Api.instance).not_to receive(:prisoner_visiting_availability)

        expect(subject.prisoner_available_dates(**prisoner_params)).to be_nil
      end

      it 'returns only prison slots if the NOMIS API cannot be contacted' do
        allow(Nomis::Api.instance).to receive(:lookup_active_prisoner)
          .and_raise(Excon::Errors::Error, 'Lookup error')
        expect(Rails.logger).to receive(:warn).with(
          'Error calling the NOMIS API: #<Excon::Error: Lookup error>'
        )

        expect(subject.prisoner_available_dates(**prisoner_params)).to be_nil
      end
    end
  end
end
