require "rails_helper"

RSpec.describe SlotAvailability do
  let(:prison)        { create(:prison_with_slots) }
  let(:offender_id)   { 'A1410AE' }
  let(:date_of_birth) { '1960-06-01' }
  let(:start_date)    { Date.parse('2017-02-01') }
  let(:end_date)      { Date.parse('2017-03-01') }
  let(:prisoner)      { Nomis::Prisoner.new(id: 1_055_206, noms_id: 'prisoner_number') }
  let(:prisoner_availability) do
    Nomis::PrisonerAvailability.new(
      dates: [
        "2017-2-13",
        "2017-2-14",
        "2017-2-20",
        "2017-2-21",
        "2017-2-27",
        "2017-2-28"
      ]
    )
  end

  let(:unavailable_slot) { '2017-02-28T09:00/10:00' }

  let(:slot_availability) do
    instance_double(SlotAvailabilityValidation, valid?: false)
  end

  subject do
    described_class.new(prison, offender_id, date_of_birth, start_date..end_date)
  end

  def all_slots_available
    tuples = prison.available_slots.map { |slot| [slot.to_s, []] }
    Hash[tuples]
  end

  def bookable_slots_times
    all_slots_available.
      keys.
      reject { |slot| slot == unavailable_slot }
  end

  before do
    allow(slot_availability).to receive(:slot_error) do |slot|
      bookable_slots_times.include?(slot) ? nil : 'error'
    end
  end

  around(:each) do |ex|
    travel_to Date.new(2017, 02, 01) do
      ex.run
    end
  end

  describe '#slots' do
    context 'with the api disabled' do
      before do
        switch_off_api
      end

      it { expect(subject.slots).to eq(all_slots_available) }
    end

    describe 'with prison in the slot availability trial' do
      before do
        switch_feature_flag_with(:public_prisons_with_slot_availability, [prison.name])
        mock_service_with(SlotAvailabilityValidation, slot_availability)
      end

      describe 'with a successful nomis public prisoner check api call' do
        before do
          switch_on_api
          mock_nomis_with(:lookup_active_prisoner, prisoner)
        end

        describe 'when the offender is valid' do
          before do
            mock_nomis_with(:prisoner_visiting_availability, prisoner_availability)
          end

          it 'returns a hash with unavailability reasons' do
            expect(subject.slots).to eq(
              "2017-02-07T09:00/10:00" => ['prisoner_unavailable'],
              "2017-02-07T14:00/16:10" => ['prisoner_unavailable'],
              "2017-02-13T14:00/16:10" => [],
              "2017-02-14T09:00/10:00" => [],
              "2017-02-14T14:00/16:10" => [],
              "2017-02-20T14:00/16:10" => [],
              "2017-02-21T09:00/10:00" => [],
              "2017-02-21T14:00/16:10" => [],
              "2017-02-27T14:00/16:10" => [],
              "2017-02-28T09:00/10:00" => ['prison_unavailable'],
              "2017-02-28T14:00/16:10" => []
            )
          end
        end

        describe 'with a null offender' do
          let(:prisoner) { Nomis::NullPrisoner.new }

          it 'applies the prison availability only' do
            expect(subject.slots).to eq(
              "2017-02-07T09:00/10:00" => [],
              "2017-02-07T14:00/16:10" => [],
              "2017-02-13T14:00/16:10" => [],
              "2017-02-14T09:00/10:00" => [],
              "2017-02-14T14:00/16:10" => [],
              "2017-02-20T14:00/16:10" => [],
              "2017-02-21T09:00/10:00" => [],
              "2017-02-21T14:00/16:10" => [],
              "2017-02-27T14:00/16:10" => [],
              "2017-02-28T09:00/10:00" => ['prison_unavailable'],
              "2017-02-28T14:00/16:10" => [])
          end
        end

        describe 'with an API::Error when querying the offender availability' do
          before do
            simulate_api_error_for(:prisoner_visiting_availability)
          end

          it 'applies the prison availability only' do
            expect(subject.slots).to eq(
              "2017-02-07T09:00/10:00" => [],
              "2017-02-07T14:00/16:10" => [],
              "2017-02-13T14:00/16:10" => [],
              "2017-02-14T09:00/10:00" => [],
              "2017-02-14T14:00/16:10" => [],
              "2017-02-20T14:00/16:10" => [],
              "2017-02-21T09:00/10:00" => [],
              "2017-02-21T14:00/16:10" => [],
              "2017-02-27T14:00/16:10" => [],
              "2017-02-28T09:00/10:00" => ['prison_unavailable'],
              "2017-02-28T14:00/16:10" => [])
          end
        end
      end
    end

    describe 'with a prison not in the trial' do
      before do
        switch_feature_flag_with(:public_prisons_with_slot_availability, [])
      end

      describe 'and prisoner availability enabled' do
        before do
          mock_nomis_with(:lookup_active_prisoner, prisoner)
          mock_nomis_with(:prisoner_visiting_availability, prisoner_availability)
        end

        it 'applies the prisoner availability' do
          expect(subject.slots).to eq(
            "2017-02-07T09:00/10:00" => ['prisoner_unavailable'],
            "2017-02-07T14:00/16:10" => ['prisoner_unavailable'],
            "2017-02-13T14:00/16:10" => [],
            "2017-02-14T09:00/10:00" => [],
            "2017-02-14T14:00/16:10" => [],
            "2017-02-20T14:00/16:10" => [],
            "2017-02-21T09:00/10:00" => [],
            "2017-02-21T14:00/16:10" => [],
            "2017-02-27T14:00/16:10" => [],
            "2017-02-28T09:00/10:00" => [],
            "2017-02-28T14:00/16:10" => [])
        end
      end

      describe 'and prisoner availability disabled' do
        before do
          switch_off_api
        end

        it { expect(subject.slots).to eq(all_slots_available) }
      end
    end
  end

  describe '#all_slots' do
    it 'returns a hash without unavailability reasons' do
      expect(subject.all_slots).to eq(
        "2017-02-07T09:00/10:00" => [],
        "2017-02-07T14:00/16:10" => [],
        "2017-02-13T14:00/16:10" => [],
        "2017-02-14T09:00/10:00" => [],
        "2017-02-14T14:00/16:10" => [],
        "2017-02-20T14:00/16:10" => [],
        "2017-02-21T09:00/10:00" => [],
        "2017-02-21T14:00/16:10" => [],
        "2017-02-27T14:00/16:10" => [],
        "2017-02-28T09:00/10:00" => [],
        "2017-02-28T14:00/16:10" => []
      )
    end
  end
end
