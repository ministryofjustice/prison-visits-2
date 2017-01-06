require "rails_helper"
require 'pvb/excon/instrumentation_factory'

RSpec.describe PVB::Excon::InstrumentationFactory do

  let(:start)  { double(Time) }
  let(:finish) { double(Time) }
  let(:payload)  { double(Hash) }

  describe '.for' do

    describe "with 'excon.request" do

      let(:instrumentation) { 'excon.request' }

      it 'returns an instrumentation request' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrumentation::Request)
      end
    end

    describe "with 'excon.response" do

      let(:instrumentation) { 'excon.response' }

      it 'returns an instrumentation response' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrumentation::Response)
      end
    end

    describe "with 'excon.error" do

      let(:instrumentation) { 'excon.error' }

      it 'returns an instrumentation error' do
        expect(described_class.for(instrumentation, start, finish, payload)).to be_instance_of(PVB::Excon::Instrumentation::Error)
      end
    end

  end
end
