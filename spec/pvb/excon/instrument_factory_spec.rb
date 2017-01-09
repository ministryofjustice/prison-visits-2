require "rails_helper"
require 'pvb/excon/instrument_factory'

RSpec.describe PVB::Excon::InstrumentFactory do
  let(:start)  { double(Time) }
  let(:finish) { double(Time) }
  let(:payload)  { double(Hash) }

  describe '.for' do
    describe "with 'nomis_api.request" do
      let(:instrumentation) { 'nomis_api.request' }

      it 'returns an instrumentation request' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Request)
      end
    end

    describe "with 'nomis_api.retry" do
      let(:instrumentation) { 'nomis_api.retry' }

      it 'returns an instrumentation retry' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Retry)
      end
    end

    describe "with 'nomis_api.response" do
      let(:instrumentation) { 'nomis_api.response' }

      it 'returns an instrumentation response' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Response)
      end
    end

    describe "with 'nomis_api.error" do
      let(:instrumentation) { 'nomis_api.error' }

      it 'returns an instrumentation error' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrument::Error)
      end
    end
  end
end
