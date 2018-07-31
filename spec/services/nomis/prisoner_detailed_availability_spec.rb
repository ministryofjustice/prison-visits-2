require 'rails_helper'

RSpec.describe Nomis::PrisonerDetailedAvailability do
  let(:api_slot)       { ConcreteSlot.parse('2017-01-01T14:01/16:00') }
  let(:requested_slot) { ConcreteSlot.parse('2017-01-01T14:00/16:00') }

  describe '.build' do
    let(:response_body) do
      {
        '2017-01-01' => {
          'out_of_vo' => true,
          'external_movement' => false,
          'existing_visits' => [{ 'id' => 123, slot: api_slot.to_s }]
        }
      }
    end

    it 'parses the response body' do
      object = described_class.build(response_body)
      expect(object.dates.count).to eq(1)
      date_info = object.dates.first

      expect(date_info.out_of_vo).to eq(true)
      expect(date_info.external_movement).to eq(false)
      expect(date_info.existing_visits.first.id).to eq('123')
      expect(date_info.existing_visits.first.slot.to_s).to eq(requested_slot.to_s)
    end
  end

  subject(:instance) do
    described_class.new(
      dates: [{
        date: date,
        out_of_vo: out_of_vo,
        external_movement: external_movement,
        existing_visits: existing_visits
      }]
    )
  end

  describe '#available?' do
    subject { instance.available?(requested_slot) }

    let(:date) { requested_slot.to_date }

    context 'when unavailable' do
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [{ 'slot' => api_slot.to_s, 'id' => 123 }] }

      it { is_expected.to eq(false) }
    end

    context 'when available' do
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [] }

      it { is_expected.to eq(true) }
    end
  end

  describe '#error_messages_for_slot' do
    subject { instance.error_messages_for_slot(requested_slot) }

    let(:date) { requested_slot.to_date }

    context 'when available on that day' do
      let(:out_of_vo) { false }
      let(:external_movement) { false }
      let(:existing_visits) { [] }

      it { is_expected.to be_empty }
    end

    context 'when unavailable on that day for all the reasons' do
      let(:out_of_vo) { true }
      let(:external_movement) { true }
      let(:existing_visits) { [{ 'slot' => api_slot.to_s, 'id' => 123 }] }

      it do
        is_expected.to contain_exactly(
          Nomis::PrisonerDateAvailability::OUT_OF_VO,
          Nomis::PrisonerDateAvailability::EXTERNAL_MOVEMENT,
          Nomis::PrisonerDateAvailability::BOOKED_VISIT)
      end
    end
  end
end
