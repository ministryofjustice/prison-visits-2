require 'rails_helper'

RSpec.describe Timebox do
  subject { described_class.new(seconds) }

  shared_examples_for :completes_main_block do
    it 'returns main block return value' do
      expect(result).to eq(:finished)
    end
  end

  shared_examples_for :falls_back do
    it 'returns fallback block return value' do
      expect(result).to eq(:fellback)
    end
  end

  shared_examples_for :logs_not_exceeded do
    it 'appends not exceeded to log' do
      expect(PVB::Instrumentation).to receive(:append_to_log).
        with(timebox_exceeded: false)
      expect(PVB::Instrumentation).not_to receive(:append_to_log).
        with(timebox_exceeded: true)
      result
    end
  end

  shared_examples_for :logs_exceeded do
    it 'appends exceeded to log' do
      expect(PVB::Instrumentation).to receive(:append_to_log).
        with(timebox_exceeded: true)
      expect(PVB::Instrumentation).not_to receive(:append_to_log).
        with(timebox_exceeded: false)
      result
    end
  end

  context '#run' do
    context 'fallback block given' do
      let(:result) do
        subject.run(-> { :fellback }) do
          sleep 0.2
          :finished
        end
      end

      context 'big timebox' do
        let(:seconds) { 10 }
        it_behaves_like :completes_main_block
        it_behaves_like :logs_not_exceeded
      end

      context 'small timebox' do
        let(:seconds) { 0.1 }
        it_behaves_like :falls_back
        it_behaves_like :logs_exceeded
      end

      context 'time has already expired' do
        subject { described_class.new(0.1, Time.now.to_f - 1) }
        it_behaves_like :falls_back
        it_behaves_like :logs_exceeded
      end

      context 'multiple calls' do
        it 'runs fallback when limit exceeded' do
          timebox = described_class.new(0.2)
          result1 = timebox.run(-> { :fellback }) { :finished }

          result2 = timebox.run(-> { :fellback }) {
            sleep 1
            :finished
          }

          result3 = timebox.run(-> { :fellback }) { :finished }

          expect(result1).to eq(:finished)
          expect(result2).to eq(:fellback)
          expect(result3).to eq(:fellback)
        end
      end
    end

    context 'no fallback block given' do
      let(:result) do
        subject.run do
          sleep 0.2
          :finished
        end
      end

      context 'within time limit' do
        let(:seconds) { 10 }
        it_behaves_like :completes_main_block
        it_behaves_like :logs_not_exceeded
      end

      context 'outside time limit' do
        let(:seconds) { 0.1 }

        it 'returns nil' do
          expect(result).to eq(nil)
        end

        it_behaves_like :logs_exceeded
      end
    end
  end
end
