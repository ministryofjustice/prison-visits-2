require 'rails_helper'

RSpec.describe Nomis::Offender::DateAvailability do
  subject(:instance) do
    described_class.new(
      date: date,
      banned: banned,
      out_of_vo: out_of_vo,
      external_movement: external_movement,
      existing_visits: existing_visits
    )
  end

  let(:date) { Time.zone.today }
  let(:banned) { false }
  let(:out_of_vo) { false }
  let(:external_movement) { false }
  let(:existing_visits) { [] }

  describe '#unavailable_reasons' do
    subject { instance.unavailable_reasons(slot) }

    let(:slot) do
      ConcreteSlot.new(date.year, date.month, date.day, 14, 30, 15, 30)
    end

    context 'with no visiting allowance' do
      let(:out_of_vo) { true }

      it { is_expected.to eq([described_class::OUT_OF_VO]) }
    end

    context 'when on an external movement' do
      let(:external_movement) { true }

      it { is_expected.to eq([described_class::EXTERNAL_MOVEMENT]) }
    end

    context 'with existing visits' do
      context "when different from the slot" do
        let(:existing_visits) do
          [
            {
              'slot' => ConcreteSlot.new(2017, 1, 1, 10, 30, 11, 30).to_s,
              'id' => '123'
            }
          ]
        end

        it { is_expected.to be_empty }
      end

      context "when overlaping the requested slot" do
        let(:existing_booked_slot) do
          ConcreteSlot.new(date.year, date.month, date.day, 15, 15, 16, 15)
        end
        let(:existing_visits) do
          [
            {
              'slot' => existing_booked_slot.to_s,
              'id' => '123'
            }
          ]
        end

        it { is_expected.to eq([described_class::BOOKED_VISIT]) }
      end
    end
  end

  describe '#available?' do
    subject { instance.available?(slot) }

    let(:slot) { ConcreteSlot.new(2017, 1, 1, 10, 30, 11, 30) }

    context 'with no unavailable_reasons' do
      before do
        expect(instance).
          to receive(:unavailable_reasons).
          with(slot).
          and_return([])
      end

      it { is_expected.to eq(true) }
    end

    context 'with unavailable_reasons' do
      before do
        expect(instance).
          to receive(:unavailable_reasons).
          with(slot).
          and_return([anything])
      end

      it { is_expected.to eq(false) }
    end
  end
end
