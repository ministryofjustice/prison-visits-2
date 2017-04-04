require 'rails_helper'

RSpec.describe Timebox do
  subject { described_class.new(seconds) }

  let(:result) do
    subject.run(-> { :fellback }) do
      sleep 0.2
      :finished
    end
  end

  context '#run' do
    context 'big timebox' do
      let(:seconds) { 10 }

      it 'returns block return value' do
        expect(result).to eq(:finished)
      end

      it 'appends to log' do
        expect(PVB::Instrumentation).to receive(:append_to_log).with(timebox_exceeded: false)
        result
      end
    end

    context 'small timebox' do
      let(:seconds) { 0.1 }

      it 'returns fallback value' do
        expect(result).to eq(:fellback)
      end

      it 'appends to log' do
        expect(PVB::Instrumentation).to receive(:append_to_log).with(timebox_exceeded: true)
        result
      end
    end

    context 'multiple calls' do
      it 'runs fallback when limit exceeded' do
        timebox = described_class.new(0.2)
        result1 = timebox.run(-> { :fellback }) { :finished }

        result2 = timebox.run(-> { :fellback }) {
          sleep 1
          :finished
        }

        expect(result1).to eq(:finished)
        expect(result2).to eq(:fellback)
      end
    end
  end
end
