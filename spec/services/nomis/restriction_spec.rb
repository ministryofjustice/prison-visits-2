require 'rails_helper'

RSpec.describe Nomis::Restriction do
  let(:description) { 'Banned' }
  let(:type) { { 'code' => "BAN", 'desc' => description } }
  let(:effective_date) { 3.days.ago.to_date }
  let(:expiry_date) { nil }

  subject do
    described_class.new(type:,
                        effective_date:,
                        expiry_date:)
  end

  it { expect(subject.description).to eq(description) }
  it { expect(subject.type).to be_instance_of(Nomis::Restriction::Type) }

  describe '#banned?' do
    context 'with a banned restriction type' do
      let(:type) { { 'code' => "BAN", 'desc' => "Banned" } }

      it { is_expected.to be_banned }
    end

    context 'with not a banned restriction type' do
      let(:type) { { 'code' => "CLOSED", 'desc' => "Closed" } }

      it { is_expected.not_to be_banned }
    end
  end

  describe '#closed?' do
    context 'with a banned restriction type' do
      let(:type) { { 'code' => "BAN", 'desc' => "Banned" } }

      it { expect(subject).not_to be_closed }
    end

    context 'with no banned restriction types' do
      let(:type) { { 'code' => "CLOSED", 'desc' => "Closed" } }

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

      context 'when before the expiry date' do
        let(:expiry_date) { date + 1.day }

        it { is_expected.to be_effective_at(date) }
      end

      context 'when after the expiry date' do
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
