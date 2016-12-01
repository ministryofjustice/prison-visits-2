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

  describe '.time_and_log' do
    it 'requires a block' do
      expect { described_class.time_and_log(:arg, 'arg') }.to raise_error(/Block required/)
    end

    it 'yields the block' do
      expect { |b| described_class.time_and_log(:arg, 'arg', &b) }.to yield_with_no_args
    end

    it 'logs the message' do
      expect(Rails.logger).to receive(:info).with(/arg/)
      described_class.time_and_log(:arg, 'arg') { true }
    end

    it 'returns the result of the block' do
      expect(described_class.time_and_log(:arg, 'arg') { 1 + 1 }).to eq(2)
    end

    context 'timing' do
      it 'calculates the run time of the block' do
        expect(Rails.logger).to receive(:info).with(/5000.00ms/)
        described_class.time_and_log(:arg, 'arg') do
          true
        end
      end
    end

    context 'categories' do
      it 'appends/adds to the correct category' do
        described_class.time_and_log('fu', :bar) do
          true
        end
        expect(described_class.custom_log_items[:bar]).to eq(5000)
      end

      it 'does not require a category' do
        expect(described_class).not_to receive(:append_to_log)
        described_class.time_and_log('A prisoner API call') do
          true
        end
      end

      context 'timing' do
        it 'adds time to an existing category' do
          described_class.append_to_log(long_time: 1000)
          described_class.time_and_log('fubar', :long_time) do
            true
          end
          expect(described_class.custom_log_items[:long_time]).to eq(6000)
        end
      end
    end
  end
end
