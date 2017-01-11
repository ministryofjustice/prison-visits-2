# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MetricsPresenter do
  let(:counts) { {} }
  let(:overdue_counts) { {} }
  let(:percentiles) { {} }
  let(:rejections) { {} }
  let(:timings) { {} }
  let(:prison_name) { 'Cardiff' }

  let(:instance) do
    described_class.new(
      counts: counts,
      overdue_counts: overdue_counts,
      percentiles: percentiles,
      rejections: rejections,
      timings: timings
    )
  end

  describe '#total_visits' do
    subject { instance.total_visits(prison_name) }

    before do
      allow_any_instance_of(PrisonSummaryMetricsPresenter).
        to receive(:total_visits).and_return(5)
    end

    it { is_expected.to eq(5) }
  end

  describe '#visits_in_state' do
    let(:state) { 'requested' }
    subject { instance.visits_in_state(prison_name, state) }

    before do
      allow_any_instance_of(PrisonSummaryMetricsPresenter).
        to receive(:visits_in_state).with(state).and_return(3)
    end

    it { is_expected.to eq(3) }
  end

  describe '#overdue_count' do
    subject { instance.overdue_count(prison_name) }

    before do
      allow_any_instance_of(PrisonSummaryMetricsPresenter).
        to receive(:processed_overdue).and_return(2)
    end

    it { is_expected.to eq(2) }
  end

  describe '#end_to_end_percentile' do
    let(:percentile) { '99th' }
    subject { instance.end_to_end_percentile(prison_name, percentile) }

    before do
      allow_any_instance_of(PrisonSummaryMetricsPresenter).
        to receive(:end_to_end_percentile).with(percentile).and_return(1)
    end

    it { is_expected.to eq(1) }
  end

  describe '#percent_rejected' do
    let(:name) { 'total' }
    subject { instance.percent_rejected(prison_name, name) }

    before do
      allow_any_instance_of(PrisonSummaryMetricsPresenter).
        to receive(:percent_rejected).with(name).and_return(0.38)
    end

    it { is_expected.to eq(0.38) }
  end

  describe '#summary_for' do
    let(:name) { 'Cardiff' }
    subject { instance.summary_for(name) }

    it { is_expected.to be_instance_of(PrisonSummaryMetricsPresenter) }

    it 'memoizes a prisons summary presenter' do
      expect(PrisonSummaryMetricsPresenter).
        to receive(:new).with(anything).once.and_call_original

      instance.summary_for(name)
      instance.summary_for(name)
    end
  end

  describe '#build_summary_for' do
    let(:counts) do
      {
        name => 'Prison counts',
        'other' => 'bar'
      }
    end
    let(:overdue_counts) do
      {
        name => 'Prison overdue count',
        'other' => 'bar'
      }
    end
    let(:percentiles) do
      {
        name => 'Prison percentiles',
        'other' => 'bar'
      }
    end
    let(:rejections) do
      {
        name => 'Prison rejections',
        'other' => 'bar'
      }
    end
    let(:timings) do
      {
        name => 'Prison timings',
        'other' => 'bar'
      }
    end
    let(:name) { 'Cardiff' }

    subject { instance.build_summary_for(name) }

    before do
      expect(PrisonSummaryMetricsPresenter).to receive(:new).
        with(counts: 'Prison counts', overdue_count: 'Prison overdue count',
             percentiles: 'Prison percentiles', rejections: 'Prison rejections',
             timings: 'Prison timings').
        and_call_original
    end

    it { is_expected.to be_instance_of(PrisonSummaryMetricsPresenter) }
  end
end
