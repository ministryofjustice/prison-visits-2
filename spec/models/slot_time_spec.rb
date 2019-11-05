# frozen_string_literal:true

require 'rails_helper'

RSpec.describe SlotTime, type: :model do
  it 'has a valid factory' do
    expect(build(:slot_time)).to be_valid
  end

  context 'when end not after begin' do
    let(:st) { build(:slot_time, begin_hour: 10, begin_minute: 0, end_hour: 10, end_minute: 0) }

    it 'is invalid' do
      expect(st).to be_invalid
    end
  end
end
