# frozen_string_literal: true
require 'rails_helper'

RSpec.describe PrisonSummaryMetricsPresenter do
  let(:timings) { nil }
  let(:counts) { nil }
  let(:percentiles) { nil }
  let(:overdue_count) { nil }
  let(:rejections) { nil }

  let(:instance) do
    described_class.new(
      timings: timings,
      counts: counts,
      percentiles: percentiles,
      overdue_count: overdue_count,
      rejections: rejections
    )
  end

  describe '#processed_on_time' do
    subject { instance.processed_on_time }

    context 'no prison data' do
      let(:timmings) { nil }

      it { is_expected.to eq(0) }
    end

    context 'no "on time" data' do
      let(:timings) do
        {
          'overdue' => { 'booked' => 3, 'rejected' => 1 }
        }
      end

      it { is_expected.to eq(0) }
    end

    context 'with "on time" data' do
      let(:timings) do
        {
          'timely' => { 'booked' => 1, 'rejected' => 2 },
          'overdue' => { 'booked' => 3, 'rejected' => 1 }
        }
      end

      it { is_expected.to eq(3) }
    end
  end

  describe '#processed_overdue' do
    subject { instance.processed_overdue }

    context 'no prison data' do
      let(:timings) { nil }

      it { is_expected.to eq(0) }
    end

    context 'no "overdue" data' do
      let(:timings) do
        {
          'timely' => { 'booked' => 3, 'rejected' => 1 }
        }
      end

      it { is_expected.to eq(0) }
    end

    context 'with "overdue" data' do
      let(:timings) do
        {
          'timely' => { 'booked' => 1, 'rejected' => 2 },
          'overdue' => { 'booked' => 3, 'rejected' => 1 }
        }
      end

      it { is_expected.to eq(4) }
    end
  end

  describe '#total visits' do
    subject { instance.total_visits }

    context 'no prison data' do
      let(:counts) { nil }

      it { is_expected.to eq(0) }
    end

    context 'with prison data' do
      let(:counts) do
        {
          'requested' => 1,
          'booked' => 4
        }
      end

      it { is_expected.to eq(5) }
    end
  end

  describe '#visits_in_state' do
    let(:state) { nil }
    subject { instance.visits_in_state(state) }

    context 'no prison data' do
      let(:counts) { nil }

      it { is_expected.to eq(0) }
    end

    context 'with prison data' do
      let(:state) { 'requested' }
      let(:counts) do
        {
          'requested' => 1,
          'booked' => 4
        }
      end

      it { is_expected.to eq(1) }
    end
  end

  describe '#overdue_count' do
    subject { instance.overdue_count }

    context 'no prison data' do
      let(:overdue_count) { nil }

      it { is_expected.to eq(0) }
    end

    context 'with prison data' do
      context 'with overdue visits' do
        let(:overdue_count) { { 'requested' => 5 } }

        it { is_expected.to eq(5) }
      end

      context 'with no overdue visits' do
        let(:overdue_count) { { 'booked' => 5 } }

        it { is_expected.to eq(0) }
      end
    end
  end

  describe '#end_to_end_percentile' do
    let(:percentile) { nil }
    subject { instance.end_to_end_percentile(percentile) }

    context 'no prison data' do
      let(:percentiles) { nil }

      it { is_expected.to eq(0) }
    end

    context 'with percentiles' do
      let(:percentiles) do
        { 99 => 518_400,
          95 => 432_000,
          90 => 345_600,
          75 => 259_200,
          50 => 172_800,
          25 => 86_400 }
      end

      context '99th percentile' do
        let(:percentile) { '99th' }
        it { is_expected.to eq('6.00') }
      end

      context '95th percentile' do
        let(:percentile) { '95th' }
        it { is_expected.to eq('5.00') }
      end

      context '90th percentile' do
        let(:percentile) { '90th' }
        it { is_expected.to eq('4.00') }
      end

      context '75th percentile' do
        let(:percentile) { '75th' }
        it { is_expected.to eq('3.00') }
      end

      context '50th percentile' do
        let(:percentile) { '50th' }
        it { is_expected.to eq('2.00') }
      end

      context '25th percentile' do
        let(:percentile) { '25th' }
        it { is_expected.to eq('1.00') }
      end
    end
  end

  describe '#percent_rejected' do
    let(:name) { 'total' }
    subject { instance.percent_rejected(name) }

    context 'no data for the prison' do
      let(:rejections) { nil }

      it { is_expected.to eq('0') }
    end

    context 'no data for the specific metric' do
      let(:rejections) { { 'something' => 3 } }

      it { is_expected.to eq('0') }
    end

    context 'with a present metric' do
      let(:rejections) do
        { name => BigDecimal.new(0.4, 2) }
      end

      it { is_expected.to eq('0.4') }
    end
  end
end
