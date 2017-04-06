require "rails_helper"

RSpec.describe SlotAvailability do
  let(:prison)        { create(:prison) }
  let(:offender_id)   { 'A1410AE' }
  let(:date_of_birth) { '1960-06-01' }
  let(:start_date)    { Date.parse('2017-02-01') }
  let(:end_date)      { Date.parse('2017-03-01') }

  let(:prisoner_availability) do
    {
      dates: [
        Date.new(2017, 2, 13),
        Date.new(2017, 2, 14),
        Date.new(2017, 2, 20),
        Date.new(2017, 2, 21),
        Date.new(2017, 2, 27),
        Date.new(2017, 2, 28)
      ]
    }
  end

  let(:unavailable_slot) { '2017-02-28T09:00/10:00' }

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

  let(:slot_availability) do
    double(SlotAvailabilityValidation, valid?: false)
  end

  before do
    allow(Nomis::Api.instance).to receive(:lookup_active_offender).
      and_return(Nomis::Offender.new(id: 1_055_206))

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
    describe 'with prison in the slot availability trial' do
      before do
        allow(Rails.configuration).
          to receive(:public_prisons_with_slot_availability).
          and_return([prison.name])
      end

      describe 'with nomis public prisoner check enabled' do
        describe 'when the offender is valid' do
          before do
            allow(Nomis::Api.instance).
              to receive(:offender_visiting_availability).
              and_return(prisoner_availability)

            expect(SlotAvailabilityValidation).
              to receive(:new).
              and_return(slot_availability)
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
          before do
            expect(Nomis::Api.instance).
              to receive(:lookup_active_offender).
              and_return(Nomis::NullOffender.new)

            expect(SlotAvailabilityValidation).
              to receive(:new).
              and_return(slot_availability)
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

        describe 'with an API::Error when querying the offender availability' do
          before do
            allow(Nomis::Api.instance).
              to receive(:offender_visiting_availability).
              and_raise(Nomis::APIError)
            expect(SlotAvailabilityValidation).
              to receive(:new).
              and_return(slot_availability)
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

      describe 'without nomis public prisoner check enabled' do
        before do
          allow(Rails.configuration).
            to receive(:nomis_public_prisoner_availability_enabled).
            and_return(false)

          expect(SlotAvailabilityValidation).
            to receive(:new).
            and_return(slot_availability)
        end

        it 'applies the prison availability' do
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
            "2017-02-28T14:00/16:10" => []
          )
        end
      end
    end

    describe 'with a prison not in the trial' do
      describe 'and prisoner availability enabled' do
        before do
          allow(Nomis::Api.instance).
            to receive(:offender_visiting_availability).
            and_return(prisoner_availability)
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
          allow(Rails.configuration).
            to receive(:nomis_public_prisoner_availability_enabled).
            and_return(false)
        end

        it { expect(subject.slots).to eq(all_slots_available) }
      end
    end
  end

  describe '#all_slots' do
    describe 'with prison in the slot availability trial' do
      before do
        allow(Rails.configuration).
          to receive(:public_prisons_with_slot_availability).
          and_return([prison.name])
      end

      describe 'with nomis public prisoner check enabled' do
        describe 'when the offender is valid' do
          before do
            allow(Nomis::Api.instance).
              to receive(:offender_visiting_availability).
              and_return(prisoner_availability)
          end

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
    end
  end
end
