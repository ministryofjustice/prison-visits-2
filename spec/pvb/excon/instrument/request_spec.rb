require "rails_helper"
require 'pvb/excon/instrument'

RSpec.describe PVB::Excon::Instrument::Request do
  let(:nowish)           { Time.now }
  let(:start)            { nowish }
  let(:finish)           { nowish + 0.5 }
  let(:payload)          { double({}) }

  subject { described_class.new(start, finish, payload) }

  describe '#process' do

    it 'increments the api_request_count' do
      expect(Instrumentation).to receive(:incr).with(:api_request_count)
      subject.process
    end

  end
end
