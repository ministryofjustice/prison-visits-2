require 'rails_helper'

RSpec.describe Nomis::Restriction do
  let(:type) { { code: "BAN", desc: "Banned" } }
  let(:effective_date) { 3.days.ago.to_date }
  let(:expiry_date) { nil }

  subject do
    described_class.new(type: type,
                        effective_date: effective_date,
                        expiry_date: expiry_date)
  end

  describe '#banned?' do
    context 'with a banned restriction type' do
      let(:type) { { code: "BAN", desc: "Banned" } }

      it { is_expected.to be_banned }
    end

    context 'with not a banned restriction type ' do
      let(:type) { { code: "CLOSED", desc: "Closed" } }

      it { is_expected.not_to be_banned }
    end
  end

  describe '#closed?' do
    context 'with a banned restriction type' do
      let(:type) { { code: "BAN", desc: "Banned" } }

      it { expect(subject).not_to be_closed }
    end

    context 'with not a banned restriction type ' do
      let(:type) { { code: "CLOSED", desc: "Closed" } }

      it { expect(subject).to be_closed }
    end
  end

  describe '#effective_at?' do
    let(:date) { Time.zone.today }

    context 'when the date is before the effective date' do
      let(:effective_date) { date + 1.day }

      it { is_expected.not_to be_effective_at(date) }
    end

    context 'when the date is after the effective date' do
      let(:effective_date) { date - 1.week }

      context 'and before the expiry date' do
        let(:expiry_date) { date + 1.day }

        it { is_expected.to be_effective_at(date) }
      end

      context 'and after the expiry date' do
        let(:expiry_date) { date - 1.day }

        it { is_expected.not_to be_effective_at(date) }
      end

      context 'with no expiry date' do
        let(:expiry_date) { nil }

        it { is_expected.to be_effective_at(date) }
      end
    end
  end
end
