# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Instrumentation do
  let!(:start_time) { Time.zone.now.utc }
  let!(:end_time) { start_time + 5.seconds }
  let!(:utc) { double('utc') }

  before do
    # Keep the timings DRY and consistent across specs.
    allow(utc).to receive(:utc).and_return(start_time, end_time)
    # `at_least` because Rails.logger uses it as well.
    allow(Time).to receive(:now).at_least(:twice).and_return(utc)

    # Because the specs get run in a single thread
    RequestStore.clear!
  end

  describe '.append_to_log' do
    it 'adds' do
      expect(described_class.append_to_log(fu: 'bar')).
        to eq(fu: 'bar')
    end

    it 'changes' do
      described_class.append_to_log(fu: 'bang')
      expect(described_class.append_to_log(fu: 'bar')).
        to eq(fu: 'bar')
    end

    it 'appends' do
      described_class.append_to_log(fu: 'bar')
      expect(described_class.append_to_log(sna: 'fu')).
        to eq(fu: 'bar', sna: 'fu')
    end
  end

  describe '.custom_log_items' do
    it 'lists all' do
      described_class.append_to_log(sna: 'fu')
      described_class.append_to_log(fu: 'bar')
      described_class.append_to_log(tar: 'fu')
      expect(described_class.custom_log_items).
        to eq(fu: 'bar',
              sna: 'fu',
              tar: 'fu')
    end
  end

  describe '.incr' do
    it 'inscrements the given counter' do
      expect {
        described_class.incr(:a_counter)
      }.to change {
        described_class.custom_log_items[:a_counter]
      }.from(nil).to(1)
    end
  end
end
