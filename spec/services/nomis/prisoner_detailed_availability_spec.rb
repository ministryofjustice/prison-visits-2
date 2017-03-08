require 'rails_helper'

RSpec.describe Nomis::PrisonerDetailedAvailability do
  describe '.build' do
    let(:response_body) do
      {
        '2017-01-01' => {
          'banned' => false,
          'out_of_vo' => true,
          'external_movement' => false,
          'existing_visits' => [{ 'id' => 123, slot: '2017-01-01T14:01/16:00' }]
        }
      }
    end

    it 'parses the response body' do
      object = described_class.build(response_body)
      expect(object.dates.size).to eq(1)
      date_info = object.dates.first

      expect(date_info.banned).to eq(false)
      expect(date_info.out_of_vo).to eq(true)
      expect(date_info.external_movement).to eq(false)
      expect(date_info.existing_visits).
        to eq([{ 'id' => 123, slot: '2017-01-01T14:01/16:00' }])
    end
  end

  subject(:instance) do
    described_class.new(
      dates: [{
        date: date,
        banned: banned,
        out_of_vo: out_of_vo,
        external_movement: external_movement,
        existing_visits: existing_visits
      }]
    )
  end

  describe '#available?' do
    subject { instance.available?(slot) }

    let(:slot) { ConcreteSlot.new(2017, 1, 1, 14, 1, 16, 0) }
    let(:date) { slot.to_date }

    context 'when unavailable' do
      let(:banned) { false }
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [{ 'slot' => slot.to_s, 'id' => 123 }] }

      it { is_expected.to eq(false) }
    end

    context 'when available' do
      let(:banned) { false }
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [] }

      it { is_expected.to eq(true) }
    end
  end

  describe '#error_messages_for_slot' do
    subject { instance.error_messages_for_slot(slot) }

    let(:slot) { ConcreteSlot.new(2017, 1, 1, 14, 1, 16, 0) }
    let(:date) { slot.to_date }

    context 'available on that day' do
      let(:banned) { false }
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [] }

      it { is_expected.to be_empty }
    end

    context 'unavailable on that day for all the reasons' do
      let(:banned) { true }
      let(:out_of_vo) { true }
      let(:external_movement) { true }
      let(:existing_visits) { [{ 'slot' => slot.to_s, 'id' => 123 }] }

      it do
        is_expected.to contain_exactly(
          Nomis::PrisonerDateAvailability::BANNED,
          Nomis::PrisonerDateAvailability::OUT_OF_VO,
          Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT,
          Nomis::PrisonerDateAvailability::BOOKED_VISIT)
      end
    end
  end
end
