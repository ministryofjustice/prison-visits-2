require 'rails_helper'

RSpec.describe MetricsPresenter do
  let(:counts) { {} }
  let(:overdue_counts) { [] }
  let(:percentiles) { [] }
  let(:rejections) { {} }
  let(:prison_name) { 'Cardiff' }

  let(:instance) do
    described_class.new(counts, overdue_counts, percentiles, rejections)
  end

  describe '#total_visits' do
    subject { instance.total_visits(prison_name) }

    it 'returns 0 if there is no data for the prison' do
      is_expected.to eq(0)
    end

    context 'with visits in different states' do
      let(:counts) do
        {
          prison_name => {
            'requested' => 2,
            'booked' => 1
          }
        }
      end

      it 'aggregates all of the visits' do
        is_expected.to eq(3)
      end
    end
  end

  describe '#visits_in_state' do
    let(:state) { 'booked' }
    subject { instance.visits_in_state(prison_name, state) }

    it 'returns 0 if there is no prison data' do
      is_expected.to eq(0)
    end

    context "with prison data but not for the given state" do
      let(:counts) do
        { prison_name => { 'requested' => 5 } }
      end

      it { is_expected.to eq(0) }
    end

    context "with prison data including the given state" do
      let(:counts) do
        { prison_name => { 'booked' => 5 } }
      end

      it { is_expected.to eq(5) }
    end
  end

  describe '#overdue_count' do
    subject { instance.overdue_count(prison_name) }

    it 'returns 0 if there is no count for the prison' do
      is_expected.to eq(0)
    end

    context "with count data" do
      let(:overdue_counts) do
        [[prison_name, anything, 2]]
      end

      it { is_expected.to eq(2) }
    end
  end

  describe '#end_to_end_percentile' do
    let(:percentile) { '99th' }
    subject { instance.end_to_end_percentile(prison_name, percentile) }

    it 'returns 0 if there is no percentile data for the prison' do
      is_expected.to eq(0)
    end

    context 'when there is data for the prison' do
      shared_examples_for 'returns each percentile' do
        context '99th percentile' do
          let(:percentile) { '99th' }
          it { is_expected.to eq('99.00') }
        end

        context '95th percentile' do
          let(:percentile) { '95th' }
          it { is_expected.to eq('95.00') }
        end

        context '90th percentile' do
          let(:percentile) { '90th' }
          it { is_expected.to eq('90.00') }
        end

        context '75th percentile' do
          let(:percentile) { '75th' }
          it { is_expected.to eq('75.00') }
        end

        context '50th percentile' do
          let(:percentile) { '50th' }
          it { is_expected.to eq('50.00') }
        end

        context '25th percentile' do
          let(:percentile) { '25th' }
          it { is_expected.to eq('25.00') }
        end
      end

      context "with all time percentiles" do
        let(:percentiles) do
          [
            [prison_name, [99.days.to_i,
                           95.days.to_i,
                           90.days.to_i,
                           75.days.to_i,
                           50.days.to_i,
                           25.days.to_i]
            ]
          ]
        end

        it_behaves_like 'returns each percentile'
      end

      context "with weekly percentiles" do
        let(:percentiles) do
          [
            [prison_name,
             anything,
             anything, [99.days.to_i,
                        95.days.to_i,
                        90.days.to_i,
                        75.days.to_i,
                        50.days.to_i,
                        25.days.to_i]
            ]
          ]
        end

        it_behaves_like 'returns each percentile'
      end
    end
  end

  context '#percent_rejected' do
    let(:name) { 'total' }
    subject { instance.percent_rejected(prison_name, name) }

    context 'no data for the prison' do
      let(:rejections) { {} }

      it { is_expected.to eq('0') }
    end

    context 'no data for the specific metric' do
      let(:rejections) { { prison_name => { 'something' => 3 } } }

      it { is_expected.to eq('0') }
    end

    context 'with a present metric' do
      let(:rejections) do
        { prison_name => { name => BigDecimal.new(0.4, 2) } }
      end

      it { is_expected.to eq('0.4') }
    end
  end
end
