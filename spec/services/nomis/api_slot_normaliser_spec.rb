require 'rails_helper'

RSpec.describe Nomis::ApiSlotNormaliser do
  subject { described_class.new(raw_slot).slot }

  describe "with a slot with correct times" do
    let(:raw_slot) { "2017-02-01T14:00/14:30" }

    it 'does nothing' do
      expect(subject.to_s).to eq(raw_slot)
    end
  end

  describe "with a slot with a begin_at out of sync" do
    let(:raw_slot) { "2017-02-01T13:59/14:30" }
    let(:correct_slot) { "2017-02-01T14:00/14:30" }

    it 'corrects the beginning time' do
      expect(subject.to_s).to eq(correct_slot)
    end
  end

  describe "with a slot with a end_at out of sync" do
    let(:raw_slot) { "2017-02-01T14:00/14:31" }
    let(:correct_slot) { "2017-02-01T14:00/14:30" }

    it 'corrects the end time' do
      expect(subject.to_s).to eq(correct_slot)
    end
  end

  describe "with a slot with both times out of sync" do
    let(:raw_slot) { "2017-02-01T14:01/14:31" }
    let(:correct_slot) { "2017-02-01T14:00/14:30" }

    it 'corrects the start and end times' do
      expect(subject.to_s).to eq(correct_slot)
    end
  end
end
