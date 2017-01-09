require "rails_helper"
require 'pvb/excon/instrument_factory'

RSpec.describe PVB::Excon::InstrumentFactory do
  let(:start)  { double(Time) }
  let(:finish) { double(Time) }
  let(:payload)  { double(Hash) }

  describe '.for' do
    describe "with 'excon.request" do
      let(:instrumentation) { 'excon.request' }

      it 'returns an instrumentation request' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Request)
      end
    end

    describe "with 'excon.retry" do
      let(:instrumentation) { 'excon.retry' }

      it 'returns an instrumentation retry' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Retry)
      end
    end

    describe "with 'excon.response" do
      let(:instrumentation) { 'excon.response' }

      it 'returns an instrumentation response' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Response)
      end
    end

    describe "with 'excon.error" do
      let(:instrumentation) { 'excon.error' }

      it 'returns an instrumentation error' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Error)
      end
    end
  end
end
