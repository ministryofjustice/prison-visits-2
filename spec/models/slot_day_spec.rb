# frozen_string_literal:true

require 'rails_helper'

RSpec.describe SlotDay, type: :model do
  it 'has a valid factory' do
    expect(build(:slot_day)).to be_valid
  end
end
