require 'rails_helper'

RSpec.describe PrisonSummaryMetricsPresenter do
  let(:timings) { nil }
  let(:counts) { nil }

  let(:instance) do
    described_class.new(timings:, counts:)
  end

  describe '#processed_overdue' do
    subject { instance.processed_overdue }

    context 'with no prison data' do
      let(:timings) { nil }

      it { is_expected.to eq(0) }
    end

    context 'with no "overdue" data' do
      let(:timings) do
        {}
      end

      it { is_expected.to eq(0) }
    end

    context 'with "overdue" data' do
      let(:timings) do
        { 'overdue' => 4 }
      end

      it { is_expected.to eq(4) }
    end
  end

  describe '#total visits' do
    subject { instance.total_visits }

    context 'with no prison data' do
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

    context 'with no prison data' do
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

  describe '#percent_rejected' do
    subject { instance.percent_rejected }

    context 'with no data for the prison' do
      it { is_expected.to eq('0.0') }
    end

    context 'with a rejected visits' do
      let(:counts) { { 'booked' => 6, 'rejected' => 4 } }

      it { is_expected.to eq(40) }
    end
  end
end
