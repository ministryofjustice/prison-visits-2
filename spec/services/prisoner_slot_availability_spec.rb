require "rails_helper"

RSpec.describe PrisonerSlotAvailability do
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
  let(:all_available_slots) do
    Hash[prison.available_slots(start_date).map { |slot| [slot.to_s, []] }]
  end

  subject do
    described_class.new(prison, offender_id, date_of_birth, start_date..end_date)
  end

  before do
    allow(Nomis::Api.instance).to receive(:lookup_active_offender).
                                    and_return(Nomis::Offender.new(id: 1_055_206))
  end

  describe '#slots' do
    describe 'with nomis public prisoner check enabled' do
      describe 'when the offender is valid' do
        before do
          allow(Nomis::Api.instance).to receive(:offender_visiting_availability).
                                          and_return(prisoner_availability)
        end

        it 'returns a hash with unavailability reasons' do
          expect(subject.slots).to eq(
            "2017-02-07T09:00/10:00" => ["prisoner_unavailable"],
            "2017-02-07T14:00/16:10" => ["prisoner_unavailable"],
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

      describe 'with a null offender' do
        before do
          expect(Nomis::Api.instance).to receive(:lookup_active_offender).and_return(Nomis::NullOffender.new)
        end

        it 'all slots should be available' do
          expect(subject.slots).to eq(all_available_slots)
        end
      end

      describe 'with an API::Error' do
        before do
          allow(Nomis::Api.instance).to receive(:offender_visiting_availability).and_raise(Nomis::APIError)
        end

        it 'all slots should be available' do
          expect(subject.slots).to eq(all_available_slots)
        end
      end
    end

    describe 'without nomis public prisoner check enabled' do
      before do
        expect(Rails.configuration).
          to receive(:nomis_public_prisoner_availability_enabled).and_return(false)
      end

      it 'all slots should be available' do
        expect(subject.slots).to eq(all_available_slots)
      end
    end
  end
end
