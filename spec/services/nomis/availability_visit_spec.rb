require 'rails_helper'

RSpec.describe Nomis::AvailabilityVisit do
  describe '#slot parsing' do
    it 'normalises the time' do
      instance = described_class.new(slot: '2015-10-23T14:00/15:31')
      expect(instance.slot.to_s).to eq('2015-10-23T14:00/15:30')
    end
  end
end
