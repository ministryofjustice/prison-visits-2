require "rails_helper"

RSpec.describe SlotAvailability do
  let(:prison)        { create(:prison) }
  let(:offender_id)   { 'A1410AE' }
  let(:date_of_birth) { '1960-06-01' }
  let(:start_date)    { Date.parse('2017-02-10') }
  let(:end_date)      { Date.parse('2017-02-21') }

  let(:prisoner_availability) do
    {
      dates: [
        Date.new(2017, 2, 13),
        Date.new(2017, 2, 20),
        Date.new(2017, 2, 21),
        Date.new(2017, 2, 27)
      ]
    }
  end

  subject do
    described_class.new(prison, offender_id, date_of_birth, start_date..end_date)
  end

  def all_slots_available
    tuples = [
      "2017-02-13T14:00/16:10",
      "2017-02-14T09:00/10:00",
      "2017-02-14T14:00/16:10",
      "2017-02-20T14:00/16:10",
      "2017-02-21T09:00/10:00",
      "2017-02-21T14:00/16:10"
    ].map { |slot| [slot, []] }
    Hash[tuples]
  end

  let(:bookable_slots) do
    Nomis::SlotAvailability.new(
      slots: all_slots_available.keys.map.with_index { |slot, _i|
        next if '2017-02-20T14:00/16:10' == slot
        { "time": slot, "capacity": 150, "max_groups": 30, "max_adults": 90, "groups_booked": 0, "visitors_booked": 0, "adults_booked": 0 }
      }.compact
    )
  end

  before do
    travel_to Date.new(2017, 02, 01)
    allow(Nomis::Api.instance).to receive(:lookup_active_offender).
                                    and_return(Nomis::Offender.new(id: 1_055_206))
  end

  after do
    travel_back
  end

  describe '#slots' do
    describe 'with prison in trial' do
      before do
        Rails.configuration.public_prisons_with_slot_availability << prison.name
      end
      describe 'with nomis public prisoner check enabled' do
        describe 'when the offender is valid' do
          before do
            allow(Nomis::Api.instance).to receive(:offender_visiting_availability).
                                            and_return(prisoner_availability)
            expect(ApiSlotAvailability).to receive(:new).
                                             and_return(double(ApiSlotAvailability, slots: bookable_slots))
          end

          it 'returns a hash with unavailability reasons' do
            expect(subject.slots).to eq("2017-02-13T14:00/16:10" => [],
                                        "2017-02-14T09:00/10:00" => ['prisoner_unavailable'],
                                        "2017-02-14T14:00/16:10" => ['prisoner_unavailable'],
                                        "2017-02-20T14:00/16:10" => ['prison_unavailable'],
                                        "2017-02-21T09:00/10:00" => [],
                                        "2017-02-21T14:00/16:10" => [])
          end
        end

        describe 'with a null offender' do
          before do
            expect(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(Nomis::NullOffender.new)
          end

          it 'all slots should be available' do
            expect(subject.slots).to eq(all_slots_available)
          end
        end

        describe 'with an API::Error' do
          before do
            allow(Nomis::Api.instance).to receive(:offender_visiting_availability).and_raise(Nomis::APIError)
          end

          it 'all slots should be available' do
            expect(subject.slots).to eq(all_slots_available)
          end
        end
      end

      describe 'without nomis public prisoner check enabled' do
        before do
          expect(Rails.configuration).
            to receive(:nomis_public_prisoner_availability_enabled).and_return(false)
        end

        it 'all slots should be available' do
          expect(subject.slots).to eq(all_slots_available)
        end
      end
    end

    describe 'with a prison not is trial' do
      it 'all slots should be available' do
        expect(subject.slots).to eq(all_slots_available)
      end
    end
  end
end
