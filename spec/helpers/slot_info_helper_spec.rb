require 'rails_helper'

RSpec.describe SlotInfoHelper, type: :helper do
  let(:slot) { '1400-1610' }

  describe '#colon_formatted_slot' do
    it { expect(helper.colon_formatted_slot(slot)).to eq('14:00 - 16:10') }
  end
end
