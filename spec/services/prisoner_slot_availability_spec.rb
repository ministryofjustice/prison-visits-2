require "rails_helper"

RSpec.describe PrisonerSlotAvailability do

  let(:prison)     { create(:prison) }
  let(:offender)   { Nomis::Offender.new(id: '1055206') }
  let(:start_date) { Date.current }
  let(:end_date)   { 60.days.from_now.to_date }

  subject do
    described_class.new(prison, offender, start_date, end_date)
  end

  describe '#slots', vcr: {  cassette_name: :prisoner_availability } do
    describe 'when the offender is valid' do
      it 'returns a hash with unavailability reasons' do
        expect(subject.slots).to eq(
                                   ConcreteSlot.new(2017, 2, 14, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 2, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => ["prisoner_unavailable"],
                                   ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0 ).to_s => [],
                                 )
      end
    end

    describe 'with a null offender' do
      let(:offender) { Nomis::NullOffender.new }
      it 'all slots should be available' do
        expect(subject.slots).to eq(
                                   ConcreteSlot.new(2017, 2, 14, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0 ).to_s => [],
                                 )
      end
    end

    describe 'with an API::Error' do

      before do
        allow(Nomis::Api.instance).to receive(:offender_visiting_availability).and_raise(Nomis::APIError)
      end

      it 'all slots should be available' do
        expect(subject.slots).to eq(
                                   ConcreteSlot.new(2017, 2, 14, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 21, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 2, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 28, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 2, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 13, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 14, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 14, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 20, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 21, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 21, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 27, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 28, 14, 0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 28, 9,  0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 3, 6, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 7, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 3, 7, 9,   0, 10, 0 ).to_s => [],
                                   ConcreteSlot.new(2017, 4, 3, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 4, 4, 14,  0, 16, 10).to_s => [],
                                   ConcreteSlot.new(2017, 4, 4, 9,   0, 10, 0 ).to_s => [],
                                 )
      end

    end
  end
end
