# frozen_string_literal:true

require 'rails_helper'

RSpec.describe SlotTime, type: :model do
  it 'has a valid factory' do
    expect(build(:slot_time)).to be_valid
  end
end
