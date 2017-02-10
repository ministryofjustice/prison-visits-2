require "rails_helper"

RSpec.describe PrisonerSlotAvailability do
  let(:prison) { create(:prison) }
  let(:offender_id) { 'A1410AE' }
  let(:date_of_birth) { '1960-06-01' }
  let(:start_date) { '2017-02-10' }
  let(:end_date)   { '2017-04-11' }

  subject do
    described_class.new(prison, offender_id, date_of_birth, start_date, end_date)
  end

  describe '#slots', vcr: { cassette_name: :prisoner_availability } do
    describe 'when the offender is valid' do
      it 'returns a hash with unavailability reasons' do
        expect(subject.slots).to eq(
          ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => ["prisoner_unavailable"],
          ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 10, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 11, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 11, 14, 0, 16, 10).to_s => ["prisoner_unavailable"]
        )
      end
    end

    describe 'with a null offender' do
      let(:offender_id) { 'does_not_exists' }
      it 'all slots should be available' do
        expect(subject.slots).to eq(
          ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 10, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 11, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 11, 14, 0, 16, 10).to_s => []
        )
      end
    end

    describe 'with an API::Error' do
      before do
        allow(Nomis::Api.instance).to receive(:offender_visiting_availability).and_raise(Nomis::APIError)
      end

      it 'all slots should be available' do
        expect(subject.slots).to eq(
          ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 10, 14, 0, 16, 10).to_s => [],
          ConcreteSlot.new(2017, 4, 11, 9,  0, 10, 0).to_s  => [],
          ConcreteSlot.new(2017, 4, 11, 14, 0, 16, 10).to_s => []
        )
      end
    end
  end
end
