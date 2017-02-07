require 'rails_helper'

RSpec.describe Nomis::ApiSlot do
  subject do
    described_class.new(time: unparsed_slot,
                        capacity: 4,
                        max_groups: 3,
                        groups_booked: 1,
                        adults_booked: 1)
  end

  let(:unparsed_slot) { '2015-10-23T14:00/15:30' }
  let(:parsed_slot) { ConcreteSlot.parse(unparsed_slot) }

  describe '#to_s' do
    it { expect(subject.to_s).to eq(parsed_slot.to_s) }
  end

  describe '#to_date' do
    it { expect(subject.to_date).to eq(parsed_slot.to_date) }
  end

  describe '<=>' do
    let(:other) { described_class.new(time: '2016-10-23T14:00/15:30') }

    it 'is -1 when the other value is later in the future' do
      expect(subject.<=>(other)).to eq(-1)
    end
  end
end
